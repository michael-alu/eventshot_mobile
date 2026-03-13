import 'package:equatable/equatable.dart';

class EventMember extends Equatable {
  const EventMember({
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

  @override
  List<Object?> get props => [id, eventId, attendeeName, joinedAt, isActive];
}
