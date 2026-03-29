import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/cards/info_banner.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('InfoBanner', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(
        const InfoBanner(title: 'Upgrade your plan'),
      ));
      expect(find.text('Upgrade your plan'), findsOneWidget);
    });

    testWidgets('does not render subtitle when not provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const InfoBanner(title: 'Only a title'),
      ));
      // Should only have one Text widget (the title)
      expect(find.text('Only a title'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const InfoBanner(
          title: 'Storage almost full',
          subtitle: 'You have used 90% of your storage.',
        ),
      ));
      expect(find.text('Storage almost full'), findsOneWidget);
      expect(find.text('You have used 90% of your storage.'), findsOneWidget);
    });

    testWidgets('renders action button when actionLabel and onAction are provided', (tester) async {
      await tester.pumpWidget(_wrap(
        InfoBanner(
          title: 'Trial ending',
          actionLabel: 'Upgrade',
          onAction: () {},
        ),
      ));
      expect(find.text('Upgrade'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('does not render action button when actionLabel is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const InfoBanner(title: 'Info only'),
      ));
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('action button callback fires on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        InfoBanner(
          title: 'Tap me',
          actionLabel: 'Go',
          onAction: () => tapped = true,
        ),
      ));
      await tester.tap(find.text('Go'));
      expect(tapped, isTrue);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const InfoBanner(
          title: 'Warning',
          icon: Icons.warning_amber_rounded,
        ),
      ));
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders default icon when icon not specified', (tester) async {
      await tester.pumpWidget(_wrap(
        const InfoBanner(title: 'Default icon'),
      ));
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
