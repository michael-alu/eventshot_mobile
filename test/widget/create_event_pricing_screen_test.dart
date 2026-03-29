import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/checkout/presentation/create_event_pricing_screen.dart';
import 'package:eventshot_mobile/features/checkout/presentation/providers/pricing_providers.dart';
import 'package:eventshot_mobile/features/checkout/domain/entities/tier.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventshot_mobile/features/events/domain/entities/event.dart';
import 'package:eventshot_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:eventshot_mobile/features/events/presentation/providers/event_providers.dart';

// Pre-subscribes authStateProvider so it's initialized before _submit() reads it.
class _AuthPreloader extends ConsumerWidget {
  final Widget child;
  const _AuthPreloader({required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authStateProvider);
    return child;
  }
}

class _FakeEventRepo implements EventRepository {
  @override
  Future<Event> createEvent({required String name, required DateTime date, required String tierId, required String organizerId}) async {
    return Event(id: 'new1', name: name, date: date, tierId: tierId, organizerId: organizerId);
  }
  @override
  Future<Event?> getEvent(String eventId) async => null;
  @override
  Stream<Event?> watchEvent(String eventId) => Stream.value(null);
  @override
  Future<void> updateEvent(Event event) async {}
  @override
  Future<void> deleteEvent(String eventId) async {}
  @override
  Stream<List<Event>> getOrganizerEvents(String organizerId) => Stream.value([]);
}

Widget _buildSubject() {
  final router = GoRouter(
    initialLocation: '/pricing',
    routes: [
      GoRoute(path: '/pricing', builder: (ctx, _) => const CreateEventPricingScreen()),
      GoRoute(path: '/organizer/dashboard', builder: (ctx, _) => const _Stub()),
    ],
  );

  const fakeOrganizer = Organizer(id: 'org-1', email: 'a@b.com', displayName: 'Alice');

  final fakeTiers = [
    Tier(id: 'free', name: 'Free Tier', description: 'Basic', priceCents: 0, features: ['100 photos']),
    Tier(id: 'pro', name: 'Pro Tier', description: 'Best value', priceCents: 4900, features: ['1000 photos'], isPopular: true),
  ];

  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith((_) => Stream.value(fakeOrganizer)),
      eventRepositoryProvider.overrideWithValue(_FakeEventRepo()),
      tiersProvider.overrideWithValue(fakeTiers),
    ],
    child: _AuthPreloader(child: MaterialApp.router(routerConfig: router)),
  );
}

void main() {
  group('CreateEventPricingScreen', () {
    testWidgets('renders screen title and layout', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Create Event'), findsWidgets);
      expect(find.text('Event Name'), findsOneWidget);
      expect(find.text('Event Date'), findsOneWidget);
      expect(find.text('Select Photo Tier'), findsOneWidget);
    });

    testWidgets('renders Create & Generate QR button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Create & Generate QR'), findsOneWidget);
    });

    testWidgets('renders all tier cards from provider', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Free Tier'), findsOneWidget);

      // Swipe to next page to see Pro Tier depending on viewport
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Pro Tier'), findsOneWidget);
    });

    testWidgets('submitting empty name does not navigate', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      // Tap submit without a name
      await tester.tap(find.text('Create & Generate QR'));
      await tester.pumpAndSettle();

      // Stays on the create event screen
      expect(find.text('Create & Generate QR'), findsOneWidget);
    });

    testWidgets('submitting with event name navigates to dashboard', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Summer Party');
      await tester.pump();

      await tester.tap(find.text('Create & Generate QR'));
      await tester.pumpAndSettle();

      // After successful create, should no longer be on the create event screen
      expect(find.text('Create & Generate QR'), findsNothing);
    });

    testWidgets('submitting with no auth user shows cannot sign in snackbar', (tester) async {
      final router = GoRouter(
        initialLocation: '/pricing',
        routes: [
          GoRoute(path: '/pricing', builder: (ctx, st) => const CreateEventPricingScreen()),
          GoRoute(path: '/organizer/dashboard', builder: (ctx, st) => const _Stub()),
        ],
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authStateProvider.overrideWith((_) => Stream.value(null)),
          eventRepositoryProvider.overrideWithValue(_FakeEventRepo()),
          tiersProvider.overrideWithValue([]),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'My Event');
      await tester.pump();

      await tester.tap(find.text('Create & Generate QR'));
      await tester.pumpAndSettle();

      expect(find.textContaining('sign in'), findsOneWidget);
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
