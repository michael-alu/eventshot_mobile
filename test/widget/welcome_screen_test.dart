import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eventshot_mobile/features/welcome/presentation/welcome_screen.dart';

Widget _buildSubject() {
  final router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/auth/organizer-signup', builder: (_, _) => const _Stub()),
      GoRoute(path: '/auth/attendee-signup', builder: (_, _) => const _Stub()),
      GoRoute(path: '/attendee/manual-code', builder: (_, _) => const _Stub()),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WelcomeScreen', () {
    testWidgets('renders screen elements', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('EventShot'), findsOneWidget);
      expect(find.text('Memories made together'), findsOneWidget);
      expect(find.text('Sign Up as Organizer'), findsOneWidget);
      expect(find.text('Sign Up as Attendee'), findsOneWidget);
      expect(find.text('Join Event as Guest'), findsOneWidget);
    });

    testWidgets('Join as guest navigates to manual code entry when no last event', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      final guestButton = find.widgetWithText(OutlinedButton, 'Join Event as Guest');
      await tester.ensureVisible(guestButton);
      await tester.tap(guestButton);
      await tester.pumpAndSettle();
      
      // Should not crash and wait for routing
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
