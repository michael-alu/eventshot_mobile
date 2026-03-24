import 'dart:math';

import '../../domain/entities/event.dart';

class EventModel {
  const EventModel({
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

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      tierId: json['tierId'] as String,
      organizerId: json['organizerId'] as String?,
      joinCode: json['joinCode'] as String? ?? '',
      maxPhotos: json['maxPhotos'] as int? ?? -1,
      qrData: json['qrData'] as String? ?? '',
      photoCount: json['photoCount'] as int? ?? 0,
      attendeeCount: json['attendeeCount'] as int? ?? 0,
      storageBytes: json['storageBytes'] as int? ?? 0,
      totalSize: json['totalSize'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'tierId': tierId,
      if (organizerId != null) 'organizerId': organizerId,
      'joinCode': joinCode,
      'maxPhotos': maxPhotos,
      'qrData': qrData,
      'photoCount': photoCount,
      'attendeeCount': attendeeCount,
      'storageBytes': storageBytes,
      'totalSize': totalSize,
    };
  }

  Event toEntity() => Event(
        id: id,
        name: name,
        date: date,
        tierId: tierId,
        organizerId: organizerId,
        joinCode: joinCode,
        maxPhotos: maxPhotos,
        qrData: qrData,
        photoCount: photoCount,
        attendeeCount: attendeeCount,
        storageBytes: storageBytes,
        totalSize: totalSize,
      );

  /// Generates a random 6-character alphanumeric join code.
  static String generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
