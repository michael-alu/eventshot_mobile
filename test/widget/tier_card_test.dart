import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/cards/tier_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('TierCard', () {
    testWidgets('renders title, subtitle, and price', (tester) async {
      await tester.pumpWidget(_wrap(
        const TierCard(
          title: 'Pro',
          subtitle: 'For professionals',
          price: r'$19',
        ),
      ));
      expect(find.text('Pro'), findsOneWidget);
      expect(find.text('For professionals'), findsOneWidget);
      expect(find.text(r'$19'), findsOneWidget);
    });

    testWidgets('renders priceSuffix in uppercase', (tester) async {
      await tester.pumpWidget(_wrap(
        const TierCard(
          title: 'Starter',
          subtitle: 'Basic plan',
          price: r'$0',
          priceSuffix: 'one-time',
        ),
      ));
      expect(find.text('ONE-TIME'), findsOneWidget);
    });

    testWidgets('renders feature list items when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const TierCard(
          title: 'Enterprise',
          subtitle: 'Unlimited everything',
          price: r'$99',
          features: ['Unlimited photos', 'Priority support'],
        ),
      ));
      expect(find.text('Unlimited photos'), findsOneWidget);
      expect(find.text('Priority support'), findsOneWidget);
    });

    testWidgets('does not render feature items when list is empty', (tester) async {
      await tester.pumpWidget(_wrap(
        const TierCard(
          title: 'Free',
          subtitle: 'Get started',
          price: r'$0',
          features: [],
        ),
      ));
      // Icons.check_circle is only in the features list
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('renders badge when badge is provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const TierCard(
          title: 'Pro',
          subtitle: 'Most popular',
          price: r'$19',
          badge: 'POPULAR',
        ),
      ));
      expect(find.text('POPULAR'), findsOneWidget);
    });

    testWidgets('does not render badge when badge is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const TierCard(
          title: 'Free',
          subtitle: 'Basic',
          price: r'$0',
        ),
      ));
      expect(find.text('POPULAR'), findsNothing);
    });

    testWidgets('shows check_circle icon when isSelected is true', (tester) async {
      await tester.pumpWidget(_wrap(
        const TierCard(
          title: 'Selected',
          subtitle: 'Active plan',
          price: r'$9',
          isSelected: true,
        ),
      ));
      // The selection indicator check_circle should be visible
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        TierCard(
          title: 'Pro',
          subtitle: 'For teams',
          price: r'$29',
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}
