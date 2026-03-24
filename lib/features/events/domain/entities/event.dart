import 'package:equatable/equatable.dart';

class Event extends Equatable {
  const Event({
    required this.id,
    required this.name,
    required this.date,
    required this.tierId,
    this.organizerId,
    this.joinCode = '',
    this.maxPhotos = -1,
    this.qrData = '',
    this.photoCount = 0,
    this.attendeeCount = 0,
    this.storageBytes = 0,
    this.totalSize = 0,
  });

  final String id;
  final String name;
  final DateTime date;
  final String tierId;
  final String? organizerId;
  final String joinCode;
  final int maxPhotos;
  final String qrData;
  final int photoCount;
  final int attendeeCount;
  final int storageBytes;
  final int totalSize;

  @override
  List<Object?> get props => [
        id,
        name,
        date,
        tierId,
        organizerId,
        joinCode,
        maxPhotos,
        qrData,
        photoCount,
        attendeeCount,
        storageBytes,
        totalSize,
      ];
}
