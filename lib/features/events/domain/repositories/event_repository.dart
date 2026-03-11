import '../entities/event.dart';

abstract class EventRepository {
  Future<Event> createEvent({
    required String name,
    required DateTime date,
    required String tierId,
    required String organizerId,
  });

  Stream<Event?> watchEvent(String eventId);

  Future<Event?> getEvent(String eventId);
}
