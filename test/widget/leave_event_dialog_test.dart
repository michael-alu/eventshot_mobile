import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eventshot_mobile/shared/widgets/dialogs/leave_event_dialog.dart';

Widget buildLeaveSubject() {
  final router = GoRouter(
    initialLocation: '/gallery',
    routes: [
      GoRoute(
        path: '/gallery',
        builder: (ctx, state) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => LeaveEventDialog.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/welcome',
        builder: (ctx, state) => const Scaffold(body: Text('Welcome')),
      ),
      GoRoute(
        path: '/auth/attendee-signup',
        builder: (ctx, state) => const Scaffold(body: Text('SignUp')),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'lastEventId': 'evt123'});
  });

  group('LeaveEventDialog', () {
    testWidgets('renders dialog with title and options', (tester) async {
      await tester.pumpWidget(buildLeaveSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Leave Event?'), findsOneWidget);
      expect(find.text('Leave Anonymously'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('shows explanation content text', (tester) async {
      await tester.pumpWidget(buildLeaveSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('create one now'), findsOneWidget);
    });

    testWidgets('Create Account button navigates to signup', (tester) async {
      await tester.pumpWidget(buildLeaveSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('SignUp'), findsOneWidget);
    });

    testWidgets('Leave Anonymously clears prefs and navigates to welcome', (tester) async {
      await tester.pumpWidget(buildLeaveSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Leave Anonymously'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
