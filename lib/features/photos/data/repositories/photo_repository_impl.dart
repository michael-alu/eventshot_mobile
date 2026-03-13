import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../models/photo_model.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  PhotoRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  static const String _collection = 'photos';

  @override
  Future<Photo> uploadPhoto({
    required File imageFile,
    required String eventId,
    required String uploaderId,
    required String uploaderName,
  }) async {
    final photoId = const Uuid().v4();
    final storagePath = 'events/$eventId/photos/$photoId.jpg';
    final storageRef = _storage.ref().child(storagePath);

    // Upload to Firebase Storage
    await storageRef.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    // Get the public download URL
    final downloadUrl = await storageRef.getDownloadURL();

    // Save metadata to Firestore
    final model = PhotoModel(
      id: photoId,
      eventId: eventId,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      firestoreUrl: downloadUrl,
      storagePath: storagePath,
      uploadedAt: DateTime.now(),
    );

    await _firestore.collection(_collection).doc(photoId).set(model.toJson());

    // Atomically increment the photo count on the event document
    await _firestore.collection('events').doc(eventId).update({
      'photoCount': FieldValue.increment(1),
    });

    return model.toEntity();
  }

  @override
  Stream<List<Photo>> watchEventPhotos(String eventId) {
    return _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .where('isActive', isEqualTo: true)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PhotoModel.fromJson({...doc.data(), 'id': doc.id}).toEntity();
      }).toList();
    });
  }

  @override
  Future<void> deletePhoto(String photoId) async {
    // Soft delete: keep the file in storage but hide it from the gallery
    await _firestore.collection(_collection).doc(photoId).update({
      'isActive': false,
    });
    
    // Note: We'd typically decrement the event.photoCount here too, 
    // but we'll need the eventId to do that cleanly.
  }

  @override
  Future<void> likePhoto(String photoId) async {
    await _firestore.collection(_collection).doc(photoId).update({
      'likesCount': FieldValue.increment(1),
    });
  }
}
