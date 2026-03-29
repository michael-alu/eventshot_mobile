import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/buttons/primary_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PrimaryButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Submit', onPressed: () {}),
      ));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Save', onPressed: () {}, isLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('does not show spinner when isLoading is false', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Save', onPressed: () {}, isLoading: false),
      ));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('fires onPressed callback on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Go', onPressed: () => tapped = true),
      ));
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('does not fire callback when onPressed is null', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Disabled', onPressed: null),
      ));
      await tester.tap(find.byType(InkWell), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('renders with icon alongside label', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Create',
          onPressed: () {},
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ));
      expect(find.text('Create'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders full-width by default', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Full Width', onPressed: () {}),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.constraints?.maxWidth, double.infinity);
    });

    testWidgets('does not fire callback when isLoading is true', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Loading',
          onPressed: () => tapped = true,
          isLoading: true,
        ),
      ));
      await tester.tap(find.byType(InkWell), warnIfMissed: false);
      expect(tapped, isFalse);
    });
  });
}
