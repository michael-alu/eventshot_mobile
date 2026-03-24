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

  /// Fetches an event by its 6-character join code. Returns null if not found.
  Future<Event?> validateJoinCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    final querySnapshot = await _firestore
        .collection('events')
        .where('joinCode', isEqualTo: cleanCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final doc = querySnapshot.docs.first;
    final data = doc.data();
    data['id'] = doc.id; // Map id correctly
    
    return EventModel.fromJson(data).toEntity();
  }

  /// Uploads a photo to Firebase Storage and registers it in Firestore.
  /// Increments the main event's `photoCount` and `storageBytes`.
  Future<void> assertUploadLimit(String eventId) async {
    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    final currentCount = eventDoc.data()?['photoCount'] ?? 0;
    if (currentCount >= 50) {
      throw Exception('This event has reached the maximum capacity of 50 photos.');
    }
  }

  /// Explicitly intended for the Background Offline Queue to invoke when internet restored
  Future<void> executeOfflineUpload(String eventId, File photoFile) async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    final photoId = const Uuid().v4();

    // 1. Upload directly to Cloudinary into organized folder: eventshot/[eventId]/images
    final downloadUrl = await CloudinaryService.uploadImage(photoFile, eventId: eventId);

    // 2. Add document to photos subcollection
    final photoDocRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('photos')
        .doc(photoId);

    // 3. Increment counters on main event document
    final eventRef = _firestore.collection('events').doc(eventId);
    final fileLength = await photoFile.length();

    // Batch write to ensure consistency
    final batch = _firestore.batch();
    
    batch.set(photoDocRef, {
      'id': photoId,
      'url': downloadUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(eventRef, {
      'photoCount': FieldValue.increment(1),
      'storageBytes': FieldValue.increment(fileLength),
    });

    await batch.commit();
  }
}
