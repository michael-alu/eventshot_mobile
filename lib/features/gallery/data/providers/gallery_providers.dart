import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/cloudinary_service.dart';

final galleryPhotosProvider = StreamProvider.family<List<String>, String>((ref, eventId) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('photos')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()['url'] as String).toList();
  });
});

/// Fetches live storage stats for an event from Cloudinary.
final cloudinaryStatsProvider =
    FutureProvider.family<CloudinaryFolderStats, String>((ref, eventId) {
  return CloudinaryService.getFolderStats(eventId: eventId);
});
