import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/core/utils/snackbar_helper.dart';

Widget buildSnackbarSubject({required VoidCallback onTap}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: onTap,
          child: const Text('Trigger'),
        ),
      ),
    ),
  );
}

void main() {
  group('SnackbarHelper', () {
    testWidgets('showError displays a snackbar with the message', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(buildSnackbarSubject(
        onTap: () => SnackbarHelper.showError(capturedContext, 'Something went wrong'),
      ));

      // Capture context first via a Consumer trick using Builder
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return ElevatedButton(
                onPressed: () => SnackbarHelper.showError(capturedContext, 'Something went wrong'),
                child: const Text('Trigger'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Trigger'));
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('showSuccess displays a snackbar with the message', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return ElevatedButton(
                onPressed: () => SnackbarHelper.showSuccess(capturedContext, 'Operation successful'),
                child: const Text('Trigger'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Trigger'));
      await tester.pump();

      expect(find.text('Operation successful'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('showError hides previous snackbar before showing new one', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () => SnackbarHelper.showError(capturedContext, 'First error'),
                    child: const Text('First'),
                  ),
                  ElevatedButton(
                    onPressed: () => SnackbarHelper.showError(capturedContext, 'Second error'),
                    child: const Text('Second'),
                  ),
                ],
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('First'));
      await tester.pump();
      expect(find.text('First error'), findsOneWidget);

      await tester.tap(find.text('Second'));
      await tester.pump();
      expect(find.text('Second error'), findsOneWidget);
    });
  });
}
