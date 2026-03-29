import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/buttons/social_auth_buttons.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    // Provide a real asset bundle that returns an empty image for the google logo
    body: child,
  ),
);

void main() {
  group('SocialAuthButtons', () {
    testWidgets('renders OR CONTINUE WITH divider text', (tester) async {
      await tester.pumpWidget(_wrap(
        SocialAuthButtons(onGooglePressed: () {}),
      ));
      expect(find.text('OR CONTINUE WITH'), findsOneWidget);
    });

    testWidgets('renders Google label', (tester) async {
      await tester.pumpWidget(_wrap(
        SocialAuthButtons(onGooglePressed: () {}),
      ));
      expect(find.text('Google'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isGoogleLoading is true', (tester) async {
      await tester.pumpWidget(_wrap(
        const SocialAuthButtons(isGoogleLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show spinner when isGoogleLoading is false', (tester) async {
      await tester.pumpWidget(_wrap(
        SocialAuthButtons(onGooglePressed: () {}),
      ));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('fires onGooglePressed when Google button tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        SocialAuthButtons(onGooglePressed: () => tapped = true),
      ));
      await tester.tap(find.byType(OutlinedButton));
      expect(tapped, isTrue);
    });
  });
}
