import 'package:equatable/equatable.dart';

class Photo extends Equatable {
  const Photo({
    required this.id,
    required this.eventId,
    required this.uploaderId,
    required this.uploaderName,
    required this.firestoreUrl,
    required this.storagePath,
    required this.uploadedAt,
    this.isActive = true,
    this.likesCount = 0,
  });

  final String id;
  final String eventId;
  final String uploaderId;
  final String uploaderName;
  final String firestoreUrl;
  final String storagePath;
  final DateTime uploadedAt;
  final bool isActive;
  final int likesCount;

  @override
  List<Object?> get props => [
        id,
        eventId,
        uploaderId,
        uploaderName,
        firestoreUrl,
        storagePath,
        uploadedAt,
        isActive,
        likesCount,
      ];
}
