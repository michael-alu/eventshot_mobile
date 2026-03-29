import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/inputs/es_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('EsTextField', () {
    testWidgets('renders label when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const EsTextField(label: 'Email'),
      ));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('does not render label text widget when label is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const EsTextField(),
      ));
      // No Text widget for label should be present
      expect(find.text('Email'), findsNothing);
    });

    testWidgets('renders hint text in the TextFormField', (tester) async {
      await tester.pumpWidget(_wrap(
        const EsTextField(hint: 'Enter your email'),
      ));
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('renders suffix widget when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        EsTextField(
          label: 'Password',
          suffix: const Icon(Icons.visibility),
        ),
      ));
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('does not render suffix when not provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const EsTextField(label: 'Name'),
      ));
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('uses controller to drive text', (tester) async {
      final controller = TextEditingController(text: 'hello@test.com');
      await tester.pumpWidget(_wrap(
        EsTextField(controller: controller, label: 'Email'),
      ));
      expect(find.text('hello@test.com'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(
        EsTextField(
          label: 'Name',
          onChanged: (v) => changed = v,
        ),
      ));
      await tester.enterText(find.byType(TextFormField), 'Alice');
      expect(changed, 'Alice');
    });

    testWidgets('renders as disabled TextFormField when enabled is false', (tester) async {
      await tester.pumpWidget(_wrap(
        const EsTextField(label: 'Read only', enabled: false),
      ));
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, false);
    });
  });
}
