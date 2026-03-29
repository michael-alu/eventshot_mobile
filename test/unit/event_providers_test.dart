import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/features/events/domain/entities/event.dart';
import 'package:eventshot_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:eventshot_mobile/features/events/presentation/providers/event_providers.dart';

/// A fake EventRepository that returns predefined events without Firebase.
class FakeEventRepository implements EventRepository {
  final List<Event> _events;

  FakeEventRepository(this._events);

  @override
  Future<Event> createEvent({
    required String name,
    required DateTime date,
    required String tierId,
    required String organizerId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Event?> getEvent(String eventId) async =>
      _events.where((e) => e.id == eventId).firstOrNull;

  @override
  Stream<Event?> watchEvent(String eventId) =>
      Stream.value(_events.where((e) => e.id == eventId).firstOrNull);

  @override
  Future<void> updateEvent(Event event) async {}

  @override
  Future<void> deleteEvent(String eventId) async {}

  @override
  Stream<List<Event>> getOrganizerEvents(String organizerId) =>
      Stream.value(_events.where((e) => e.organizerId == organizerId).toList());
}

final _testDate = DateTime(2024, 8, 10);

List<Event> _makeEvents() => [
      Event(
        id: 'evt-1',
        name: 'Beach Party',
        date: _testDate,
        tierId: 'pro',
        organizerId: 'org-1',
        joinCode: 'AAA111',
        photoCount: 10,
        attendeeCount: 5,
        storageBytes: 1000,
        totalSize: 1000,
      ),
      Event(
        id: 'evt-2',
        name: 'Office Lunch',
        date: _testDate,
        tierId: 'free',
        organizerId: 'org-1',
        joinCode: 'BBB222',
        photoCount: 20,
        attendeeCount: 8,
        storageBytes: 2000,
        totalSize: 2000,
      ),
    ];

void main() {
  group('AggregateStats', () {
    test('defaults are all zero', () {
      const stats = AggregateStats();
      expect(stats.totalEvents, 0);
      expect(stats.totalPhotos, 0);
      expect(stats.totalAttendees, 0);
      expect(stats.totalStorageBytes, 0);
      expect(stats.totalSize, 0);
    });
  });

  group('aggregateStatsProvider with fake repository', () {
    late ProviderContainer container;

    setUp(() {
      final fakeRepo = FakeEventRepository(_makeEvents());
      container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('aggregateStatsProvider returns zero stats when no events loaded', () {
      // organizerEventsProvider needs an authenticated user which we don't have
      // in this test — it returns Stream.empty() when user is null,
      // so aggregateStats defaults to zero.
      final stats = container.read(aggregateStatsProvider);
      expect(stats.totalEvents, 0);
      expect(stats.totalPhotos, 0);
      expect(stats.totalAttendees, 0);
    });
  });

  group('FakeEventRepository', () {
    final repo = FakeEventRepository(_makeEvents());

    test('getEvent returns correct event by id', () async {
      final event = await repo.getEvent('evt-1');
      expect(event?.name, 'Beach Party');
    });

    test('getEvent returns null for unknown id', () async {
      final event = await repo.getEvent('unknown');
      expect(event, isNull);
    });

    test('getOrganizerEvents streams events for organizer', () async {
      final events = await repo.getOrganizerEvents('org-1').first;
      expect(events.length, 2);
    });

    test('watchEvent streams correct event', () async {
      final event = await repo.watchEvent('evt-2').first;
      expect(event?.name, 'Office Lunch');
    });

    test('watchEvent streams null for unknown id', () async {
      final event = await repo.watchEvent('nope').first;
      expect(event, isNull);
    });
  });
}
