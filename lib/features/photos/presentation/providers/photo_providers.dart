import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../data/repositories/photo_repository_impl.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl();
});

final watchEventPhotosProvider = StreamProvider.family<List<Photo>, String>((ref, eventId) {
  final repo = ref.watch(photoRepositoryProvider);
  return repo.watchEventPhotos(eventId);
});
