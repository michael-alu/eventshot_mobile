import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/cards/section_header.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SectionHeader', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionHeader(title: 'Overview'),
      ));
      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets('does not render subtitle when not provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionHeader(title: 'Events'),
      ));
      // Only one text widget — the title
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionHeader(
          title: 'Events',
          subtitle: 'Manage your events here',
        ),
      ));
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Manage your events here'), findsOneWidget);
    });

    testWidgets('renders two Text widgets when subtitle is present', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionHeader(
          title: 'Gallery',
          subtitle: 'All uploaded photos',
        ),
      ));
      expect(find.byType(Text), findsNWidgets(2));
    });

    testWidgets('renders inside a Column without layout error', (tester) async {
      await tester.pumpWidget(_wrap(
        const Column(
          children: [
            SectionHeader(title: 'Section A'),
            SectionHeader(title: 'Section B', subtitle: 'Details'),
          ],
        ),
      ));
      expect(find.text('Section A'), findsOneWidget);
      expect(find.text('Section B'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });
  });
}
