import '../../domain/entities/event_member.dart';

class EventMemberModel {
  const EventMemberModel({
    required this.id,
    required this.eventId,
    required this.attendeeName,
    required this.joinedAt,
    this.isActive = true,
  });

  final String id;
  final String eventId;
  final String attendeeName;
  final DateTime joinedAt;
  final bool isActive;

  factory EventMemberModel.fromJson(Map<String, dynamic> json) {
    return EventMemberModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      attendeeName: json['attendeeName'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'attendeeName': attendeeName,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  EventMember toEntity() => EventMember(
        id: id,
        eventId: eventId,
        attendeeName: attendeeName,
        joinedAt: joinedAt,
        isActive: isActive,
      );
}
