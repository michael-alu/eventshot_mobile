import '../entities/event_member.dart';

abstract class EventMemberRepository {
  /// Joins an event using a join code
  Future<EventMember> joinEventWithCode({
    required String joinCode,
    required String attendeeName,
  });

  /// Streams all active members for an event
  Stream<List<EventMember>> watchEventMembers(String eventId);

  /// Leaves an event (soft delete)
  Future<void> leaveEvent(String memberId);
}
