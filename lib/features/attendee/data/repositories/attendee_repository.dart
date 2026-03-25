import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/cloudinary_service.dart';

import '../../../events/data/models/event_model.dart';
import '../../../events/domain/entities/event.dart';

final attendeeRepositoryProvider = Provider<AttendeeRepository>((ref) {
  return AttendeeRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

class AttendeeRepository {
  AttendeeRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Fetches an event by its 6-character join code.
  /// Returns null if not found or the event is at capacity (10 attendees).
  Future<Event?> validateJoinCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    final querySnapshot = await _firestore
        .collection('events')
        .where('joinCode', isEqualTo: cleanCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    final data = doc.data();
    data['id'] = doc.id;

    final event = EventModel.fromJson(data).toEntity();
    if (event.attendeeCount >= 10) {
      throw Exception('This event is full. Maximum 10 attendees allowed.');
    }

    return event;
  }

  /// Validates the photo count limit before queuing an upload.
  Future<void> assertUploadLimit(String eventId) async {
    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    final currentCount = eventDoc.data()?['photoCount'] ?? 0;
    if (currentCount >= 50) {
      throw Exception('This event has reached the maximum capacity of 50 photos.');
    }
  }

  /// Called by the Background Offline Queue when internet is restored.
  /// This method uploads to Cloudinary, writes the Firestore photo document, and increments counters.
  /// On the very first upload from this device, it also registers the attendee.
  Future<void> executeOfflineUpload(String eventId, File photoFile) async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    final uid = _auth.currentUser!.uid;
    final photoId = const Uuid().v4();
    final downloadUrl = await CloudinaryService.uploadImage(photoFile, eventId: eventId);
    
    final eventRef = _firestore.collection('events').doc(eventId);
    final eventSnap = await eventRef.get();
    final isOrganizer = eventSnap.data()?['organizerId'] == uid;

    final attendeeRef = eventRef.collection('attendees').doc(uid);

    final attendeeSnap = await attendeeRef.get();
    // If you are the organizer testing the app, we don't count you as an attendee.
    final isNewAttendee = !attendeeSnap.exists && !isOrganizer;

    final fileLength = await photoFile.length();

    final photoDocRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('photos')
        .doc(photoId);

    final batch = _firestore.batch();
    batch.set(photoDocRef, {
      'id': photoId,
      'url': downloadUrl,
      'uploadedBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (isNewAttendee) {
      batch.set(attendeeRef, {
        'id': uid,
        'name': _auth.currentUser?.displayName ?? 'Attendee',
        'photoCount': 0,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    }
    batch.update(eventRef, {
      'photoCount': FieldValue.increment(1),
      'storageBytes': FieldValue.increment(fileLength),
      'totalSize': FieldValue.increment(fileLength),
      if (isNewAttendee) 'attendeeCount': FieldValue.increment(1),
    });

    await batch.commit();
  }
}
