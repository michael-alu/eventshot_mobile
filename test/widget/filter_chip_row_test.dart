import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/chips/filter_chip_row.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('FilterChipRow', () {
    const labels = ['All', 'My Photos', 'Others'];

    testWidgets('renders all chip labels', (tester) async {
      await tester.pumpWidget(_wrap(
        const FilterChipRow(labels: labels),
      ));
      for (final label in labels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('first chip is selected by default (selectedIndex = 0)', (tester) async {
      await tester.pumpWidget(_wrap(
        const FilterChipRow(labels: labels),
      ));
      // The selected chip at index 0 renders its FilterChip with selected: true
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      expect(chips[0].selected, isTrue);
      expect(chips[1].selected, isFalse);
      expect(chips[2].selected, isFalse);
    });

    testWidgets('correct chip is selected when selectedIndex is set', (tester) async {
      await tester.pumpWidget(_wrap(
        const FilterChipRow(labels: labels, selectedIndex: 2),
      ));
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      expect(chips[0].selected, isFalse);
      expect(chips[2].selected, isTrue);
    });

    testWidgets('fires onSelected with correct index on tap', (tester) async {
      int? selected;
      await tester.pumpWidget(_wrap(
        FilterChipRow(
          labels: labels,
          onSelected: (i) => selected = i,
        ),
      ));
      await tester.tap(find.text('My Photos'));
      expect(selected, 1);
    });

    testWidgets('renders single label without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const FilterChipRow(labels: ['All']),
      ));
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders correct number of FilterChip widgets', (tester) async {
      await tester.pumpWidget(_wrap(
        const FilterChipRow(labels: labels),
      ));
      expect(find.byType(FilterChip), findsNWidgets(3));
    });
  });
}
