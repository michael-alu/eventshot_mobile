import 'dart:io';

import '../entities/photo.dart';

abstract class PhotoRepository {
  /// Uploads a photo to Firebase Storage and saves its metadata to Firestore
  Future<Photo> uploadPhoto({
    required File imageFile,
    required String eventId,
    required String uploaderId,
    required String uploaderName,
  });

  /// Streams all active photos for a specific event
  Stream<List<Photo>> watchEventPhotos(String eventId);

  /// Performs a soft delete (sets isActive to false)
  Future<void> deletePhoto(String photoId);

  /// Increments the like count for a photo
  Future<void> likePhoto(String photoId);
}
