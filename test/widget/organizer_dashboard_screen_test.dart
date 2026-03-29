import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/organizer/presentation/organizer_dashboard_screen.dart';
import 'package:eventshot_mobile/features/events/presentation/providers/event_providers.dart';
import 'package:eventshot_mobile/features/events/domain/entities/event.dart';

Widget _buildSubject({List<Event> events = const [], AggregateStats? stats}) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/dashboard', builder: (_, _) => const OrganizerDashboardScreen()),
      GoRoute(path: '/organizer/profile', builder: (_, _) => const _Stub()),
      GoRoute(path: '/create-event', builder: (_, _) => const _Stub()),
    ],
  );

  return ProviderScope(
    overrides: [
      organizerEventsProvider.overrideWith((_) => Stream.value(events)),
      if (stats != null) aggregateStatsProvider.overrideWithValue(stats),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('OrganizerDashboardScreen - empty', () {
    testWidgets('renders empty state UI when no events', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      
      expect(find.text('Welcome to EventShot'), findsOneWidget);
      expect(find.text('Create an event to see your overall dashboard and share access with attendees.'), findsOneWidget);
      expect(find.text('Create Event'), findsWidgets);
    });
  });

  group('OrganizerDashboardScreen - populated', () {
    final fakeStats = AggregateStats(
      totalEvents: 3,
      totalAttendees: 100,
      totalPhotos: 500,
      totalSize: 1048576 * 10, // 10 MB
    );
    final fakeEvents = [
      Event(id: 'EVT1', name: 'Event 1', date: DateTime.now(), joinCode: 'ABC', organizerId: 'org1', tierId: 'free'),
    ];

    testWidgets('renders stats when there are events', (tester) async {
      await tester.pumpWidget(_buildSubject(events: fakeEvents, stats: fakeStats));
      await tester.pumpAndSettle();
      
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Total Events'), findsOneWidget);
      expect(find.text('Total Photos'), findsOneWidget);
      
      // Values
      expect(find.text('3'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('10.0 MB'), findsOneWidget); 
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
