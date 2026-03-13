import '../../domain/entities/photo.dart';

class PhotoModel {
  const PhotoModel({
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

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      uploaderId: json['uploaderId'] as String,
      uploaderName: json['uploaderName'] as String,
      firestoreUrl: json['firestoreUrl'] as String,
      storagePath: json['storagePath'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      likesCount: json['likesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'firestoreUrl': firestoreUrl,
      'storagePath': storagePath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isActive': isActive,
      'likesCount': likesCount,
    };
  }

  Photo toEntity() => Photo(
        id: id,
        eventId: eventId,
        uploaderId: uploaderId,
        uploaderName: uploaderName,
        firestoreUrl: firestoreUrl,
        storagePath: storagePath,
        uploadedAt: uploadedAt,
        isActive: isActive,
        likesCount: likesCount,
      );
}
