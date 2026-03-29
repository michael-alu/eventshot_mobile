import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/user/presentation/user_dashboard_screen.dart';
import 'package:eventshot_mobile/features/events/domain/entities/event.dart';

Widget _buildSubject(List<Event> events) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/dashboard', builder: (_, _) => const UserDashboardScreen()),
      GoRoute(path: '/attendee/manual-code', builder: (_, _) => const _Stub()),
    ],
  );

  return ProviderScope(
    overrides: [
      userJoinedEventsProvider.overrideWith((_) => Future.value(events)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('UserDashboardScreen - empty', () {
    testWidgets('renders empty state UI when no events', (tester) async {
      await tester.pumpWidget(_buildSubject([]));
      await tester.pumpAndSettle();
      
      expect(find.text('My Events'), findsOneWidget);
      expect(find.text('No events yet'), findsOneWidget);
      expect(find.text('Join an event to start capturing and accessing photos.'), findsOneWidget);
      expect(find.text('Join an Event'), findsWidgets);
    });
  });

  group('UserDashboardScreen - populated', () {
    final fakeEvents = [
      Event(id: 'EVT1', name: 'Wedding Party', date: DateTime.now(), joinCode: 'ABC', organizerId: 'org1', tierId: 'free'),
      Event(id: 'EVT2', name: 'Birthday', date: DateTime.now(), joinCode: 'DEF', organizerId: 'org2', tierId: 'pro'),
    ];

    testWidgets('renders list of events', (tester) async {
      await tester.pumpWidget(_buildSubject(fakeEvents));
      await tester.pumpAndSettle();
      
      expect(find.text('Wedding Party'), findsOneWidget);
      expect(find.text('Birthday'), findsOneWidget);
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
