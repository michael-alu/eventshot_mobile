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

    // Block entry once 10 unique attendees have already uploaded
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
  /// Uploads to Cloudinary, writes Firestore photo doc, increments counters.
  /// On the very first upload from this device (anonymous UID), also
  /// registers the attendee and increments attendeeCount.
  Future<void> executeOfflineUpload(String eventId, File photoFile) async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    final uid = _auth.currentUser!.uid;
    final photoId = const Uuid().v4();

    // 1. Upload to Cloudinary (organized folder: eventshot/[eventId]/images)
    final downloadUrl = await CloudinaryService.uploadImage(photoFile, eventId: eventId);

    // 2. Check if this attendee has uploaded before (use their UID as doc ID)
    final attendeeRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('attendees')
        .doc(uid);

    final attendeeSnap = await attendeeRef.get();
    final isNewAttendee = !attendeeSnap.exists;

    final fileLength = await photoFile.length();

    final photoDocRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('photos')
        .doc(photoId);

    final eventRef = _firestore.collection('events').doc(eventId);

    // 3. Batch write for consistency
    final batch = _firestore.batch();

    // 3a. Register the photo
    batch.set(photoDocRef, {
      'id': photoId,
      'url': downloadUrl,
      'uploadedBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3b. Register attendee on their very first upload
    if (isNewAttendee) {
      batch.set(attendeeRef, {
        'uid': uid,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    }

    // 3c. Increment event counters
    batch.update(eventRef, {
      'photoCount': FieldValue.increment(1),
      'storageBytes': FieldValue.increment(fileLength),
      'totalSize': FieldValue.increment(fileLength),
      if (isNewAttendee) 'attendeeCount': FieldValue.increment(1),
    });

    await batch.commit();
  }
}
