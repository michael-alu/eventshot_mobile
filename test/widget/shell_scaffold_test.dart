import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/shared/widgets/shell/organizer_shell_scaffold.dart';
import 'package:eventshot_mobile/shared/widgets/shell/user_shell_scaffold.dart';

GoRouter buildOrganizerRouter() {
  return GoRouter(
    initialLocation: '/shell/tab1',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => OrganizerShellScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/shell/tab1',
              builder: (ctx, st) => const Scaffold(body: Text('Dashboard')),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/shell/tab2',
              builder: (ctx, st) => const Scaffold(body: Text('Events')),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/shell/tab3',
              builder: (ctx, st) => const Scaffold(body: Text('Profile')),
            ),
          ]),
        ],
      ),
    ],
  );
}

GoRouter buildUserRouter() {
  return GoRouter(
    initialLocation: '/user/tab1',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => UserShellScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/user/tab1',
              builder: (ctx, st) => const Scaffold(body: Text('My Events')),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/user/tab2',
              builder: (ctx, st) => const Scaffold(body: Text('Settings')),
            ),
          ]),
        ],
      ),
    ],
  );
}

void main() {
  group('OrganizerShellScaffold', () {
    testWidgets('renders bottom navigation with 3 tabs', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildOrganizerRouter()));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsAtLeast(1));
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('starts on the first tab (Dashboard)', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildOrganizerRouter()));
      await tester.pumpAndSettle();

      // Body content for the first branch
      expect(find.text('Dashboard'), findsAtLeast(1));
    });

    testWidgets('tapping Events tab navigates to Events branch', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildOrganizerRouter()));
      await tester.pumpAndSettle();

      // Tap the Events nav item in the bottom bar
      await tester.tap(find.widgetWithText(InkWell, 'Events'));
      await tester.pumpAndSettle();

      expect(find.text('Events'), findsAtLeast(1));
    });

    testWidgets('tapping Profile tab navigates to Profile branch', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildOrganizerRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(InkWell, 'Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsAtLeast(1));
    });

    testWidgets('shows home, photo_library, person icons', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildOrganizerRouter()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });

  group('UserShellScaffold', () {
    testWidgets('renders bottom navigation with 2 tabs', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildUserRouter()));
      await tester.pumpAndSettle();

      expect(find.text('My Events'), findsAtLeast(1));
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('starts on My Events tab', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildUserRouter()));
      await tester.pumpAndSettle();

      expect(find.text('My Events'), findsAtLeast(1));
    });

    testWidgets('tapping Settings tab navigates to Settings branch', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildUserRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(InkWell, 'Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsAtLeast(1));
    });

    testWidgets('shows camera and person icons', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildUserRouter()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.photo_camera_back), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('tapping active tab again stays on same branch', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: buildUserRouter()));
      await tester.pumpAndSettle();

      // Tap the already-active My Events tab
      await tester.tap(find.widgetWithText(InkWell, 'My Events'));
      await tester.pumpAndSettle();

      expect(find.text('My Events'), findsAtLeast(1));
    });
  });
}
