import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/shared/widgets/chrome/es_app_bar.dart';

Widget _wrapWithRouter(Widget home) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, _) => home)],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  group('EsAppBar', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrapWithRouter(
        const Scaffold(appBar: EsAppBar(title: 'Dashboard')),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('renders action widgets when provided', (tester) async {
      await tester.pumpWidget(_wrapWithRouter(
        Scaffold(
          appBar: EsAppBar(
            title: 'Events',
            actions: [
              IconButton(icon: const Icon(Icons.add), onPressed: () {}),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('does not render action SizedBox spacer when actions is null', (tester) async {
      await tester.pumpWidget(_wrapWithRouter(
        const Scaffold(appBar: EsAppBar(title: 'No Actions')),
      ));
      await tester.pumpAndSettle();
      expect(find.text('No Actions'), findsOneWidget);
    });

    testWidgets('renders preferredSize as kToolbarHeight', (tester) async {
      const appBar = EsAppBar(title: 'Test');
      expect(appBar.preferredSize.height, kToolbarHeight);
    });
  });
}
