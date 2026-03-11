import '../../domain/entities/event.dart';

class EventModel {
  const EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.tierId,
    this.organizerId,
    this.photoCount = 0,
    this.attendeeCount = 0,
    this.storageBytes = 0,
  });

  final String id;
  final String name;
  final DateTime date;
  final String tierId;
  final String? organizerId;
  final int photoCount;
  final int attendeeCount;
  final int storageBytes;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      tierId: json['tierId'] as String,
      organizerId: json['organizerId'] as String?,
      photoCount: json['photoCount'] as int? ?? 0,
      attendeeCount: json['attendeeCount'] as int? ?? 0,
      storageBytes: json['storageBytes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'tierId': tierId,
      if (organizerId != null) 'organizerId': organizerId,
      'photoCount': photoCount,
      'attendeeCount': attendeeCount,
      'storageBytes': storageBytes,
    };
  }

  Event toEntity() => Event(
        id: id,
        name: name,
        date: date,
        tierId: tierId,
        organizerId: organizerId,
        photoCount: photoCount,
        attendeeCount: attendeeCount,
        storageBytes: storageBytes,
      );
}
