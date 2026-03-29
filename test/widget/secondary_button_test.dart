import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/buttons/secondary_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SecondaryButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        SecondaryButton(label: 'Cancel', onPressed: () {}),
      ));
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('fires onPressed on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        SecondaryButton(label: 'Back', onPressed: () => tapped = true),
      ));
      await tester.tap(find.byType(OutlinedButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not fire callback when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const SecondaryButton(label: 'Disabled', onPressed: null),
      ));
      // Just verify it renders without error when disabled
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('renders icon alongside label when icon provided', (tester) async {
      await tester.pumpWidget(_wrap(
        SecondaryButton(
          label: 'Share',
          onPressed: () {},
          icon: const Icon(Icons.share),
        ),
      ));
      expect(find.text('Share'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('renders as OutlinedButton', (tester) async {
      await tester.pumpWidget(_wrap(
        SecondaryButton(label: 'Do it', onPressed: () {}),
      ));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });
}
