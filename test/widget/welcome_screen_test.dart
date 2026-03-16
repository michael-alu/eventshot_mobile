import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/welcome/presentation/welcome_screen.dart';

/// Wraps the widget under test with the minimum required ancestors.
Widget _buildSubject() {
  final router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      // Stub destinations so navigation doesn't throw
      GoRoute(
        path: '/auth/organizer-signup',
        builder: (_, __) => const _Stub(),
      ),
      GoRoute(path: '/attendee/scan', builder: (_, __) => const _Stub()),
    ],
  );

  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
  group('WelcomeScreen', () {
    testWidgets('renders app name', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('EventShot'), findsOneWidget);
    });

    testWidgets('renders organizer CTA button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text("I'm Organizing an Event"), findsOneWidget);
    });

    testWidgets('renders attendee CTA button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text("I'm an Attendee"), findsOneWidget);
    });

    testWidgets('renders tagline text', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Memories made together'), findsOneWidget);
    });

    testWidgets('tapping attendee button navigates away from welcome', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text("I'm an Attendee"));
      await tester.pumpAndSettle();

      // WelcomeScreen should no longer be visible
      expect(find.text('EventShot'), findsNothing);
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
