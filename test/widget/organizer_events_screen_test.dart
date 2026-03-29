import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/organizer/presentation/organizer_events_screen.dart';
import 'package:eventshot_mobile/features/events/domain/entities/event.dart';
import 'package:eventshot_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:eventshot_mobile/features/events/presentation/providers/event_providers.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';

class _FakeEventRepo implements EventRepository {
  final List<Event> events;
  _FakeEventRepo(this.events);

  @override
  Future<Event> createEvent({required String name, required DateTime date, required String tierId, required String organizerId}) => throw UnimplementedError();
  @override
  Future<Event?> getEvent(String eventId) async => null;
  @override
  Stream<Event?> watchEvent(String eventId) => Stream.value(null);
  @override
  Future<void> updateEvent(Event event) async {}
  @override
  Future<void> deleteEvent(String eventId) async {}
  @override
  Stream<List<Event>> getOrganizerEvents(String organizerId) => Stream.value(events);
}

final _testDate = DateTime(2024, 8, 10);

Widget _buildSubject({List<Event> events = const []}) {
  final router = GoRouter(
    initialLocation: '/events',
    routes: [
      GoRoute(path: '/events', builder: (_, _) => const OrganizerEventsScreen()),
      GoRoute(path: '/organizer/events/:id', builder: (_, _) => const _Stub()),
      GoRoute(path: '/create-event', builder: (_, _) => const _Stub()),
    ],
  );

  const fakeOrganizer = Organizer(id: 'org-1', email: 'a@b.com', displayName: 'Alice');

  return ProviderScope(
    overrides: [
      eventRepositoryProvider.overrideWithValue(_FakeEventRepo(events)),
      authStateProvider.overrideWith((_) => Stream.value(fakeOrganizer)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('OrganizerEventsScreen — empty state', () {
    testWidgets('renders No events yet message', (tester) async {
      await tester.pumpWidget(_buildSubject(events: []));
      await tester.pumpAndSettle();
      expect(find.text('No events yet'), findsOneWidget);
    });

    testWidgets('renders Create Event button in empty state', (tester) async {
      await tester.pumpWidget(_buildSubject(events: []));
      await tester.pumpAndSettle();
      expect(find.text('Create Event'), findsWidgets);
    });

    testWidgets('renders Events app bar', (tester) async {
      await tester.pumpWidget(_buildSubject(events: []));
      await tester.pumpAndSettle();
      expect(find.text('Events'), findsOneWidget);
    });
  });

  group('OrganizerEventsScreen — with events', () {
    final events = [
      Event(
        id: 'evt-1',
        name: 'Summer Gala',
        date: _testDate,
        tierId: 'pro',
        organizerId: 'org-1',
        joinCode: 'AAA111',
      ),
      Event(
        id: 'evt-2',
        name: 'Office Party',
        date: _testDate,
        tierId: 'free',
        organizerId: 'org-1',
        joinCode: 'BBB222',
      ),
    ];

    testWidgets('renders list of event names', (tester) async {
      await tester.pumpWidget(_buildSubject(events: events));
      await tester.pumpAndSettle();
      expect(find.text('Summer Gala'), findsOneWidget);
      expect(find.text('Office Party'), findsOneWidget);
    });

    testWidgets('renders event date formatted correctly', (tester) async {
      await tester.pumpWidget(_buildSubject(events: events));
      await tester.pumpAndSettle();
      // Aug 10, 2024
      expect(find.text('Aug 10, 2024'), findsWidgets);
    });

    testWidgets('renders FAB New Event button', (tester) async {
      await tester.pumpWidget(_buildSubject(events: events));
      await tester.pumpAndSettle();
      expect(find.text('New Event'), findsOneWidget);
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
