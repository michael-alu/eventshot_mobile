import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/cards/stat_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('StatCard', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatCard(label: 'Total Events', value: '12'),
      ));
      expect(find.text('Total Events'), findsOneWidget);
    });

    testWidgets('renders value text', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatCard(label: 'Photos', value: '256'),
      ));
      expect(find.text('256'), findsOneWidget);
    });

    testWidgets('renders both label and value simultaneously', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatCard(label: 'Attendees', value: '42'),
      ));
      expect(find.text('Attendees'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders with zero value', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatCard(label: 'Storage Used', value: '0 MB'),
      ));
      expect(find.text('0 MB'), findsOneWidget);
    });

    testWidgets('renders with long label without overflowing', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 200,
          child: StatCard(label: 'Total Uploaded Photos', value: '1024'),
        ),
      ));
      // If no overflow exception is thrown, the test passes
      expect(find.text('Total Uploaded Photos'), findsOneWidget);
    });
  });
}
