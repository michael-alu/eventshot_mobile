import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/shared/widgets/dialogs/qr_invite_dialog.dart';

/// The dialog is tall — give the test surface enough vertical space.
void useLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget buildQrSubject({required String joinCode, Widget? qrWidget}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => QrInviteDialog.show(
            context,
            joinCode: joinCode,
            qrWidget: qrWidget,
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

void main() {
  group('QrInviteDialog', () {
    testWidgets('renders join code characters', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildQrSubject(joinCode: 'ABC123'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Invite Attendees'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('uses provided qrWidget instead of default QrImageView', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildQrSubject(
        joinCode: 'XYZ999',
        qrWidget: const Text('CUSTOM_QR'),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('CUSTOM_QR'), findsOneWidget);
    });

    testWidgets('close button dismisses dialog', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildQrSubject(joinCode: 'TEST99', qrWidget: const SizedBox()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Invite Attendees'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Invite Attendees'), findsNothing);
    });

    testWidgets('Copy Link button triggers clipboard and closes dialog', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildQrSubject(joinCode: 'LNK123', qrWidget: const SizedBox()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy Link'));
      await tester.pumpAndSettle();

      expect(find.text('Invite Attendees'), findsNothing);
    });

    testWidgets('Copy Code button triggers clipboard and closes dialog', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildQrSubject(joinCode: 'COD456', qrWidget: const SizedBox()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy Code'));
      await tester.pumpAndSettle();

      expect(find.text('Invite Attendees'), findsNothing);
    });

    testWidgets('shows instruction text and manual join code label', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildQrSubject(joinCode: 'ABCDEF', qrWidget: const SizedBox()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Scan the QR code'), findsOneWidget);
      expect(find.text('MANUAL JOIN CODE'), findsOneWidget);
    });

    testWidgets('pads short join code to 6 chars without throwing', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildQrSubject(joinCode: 'AB', qrWidget: const SizedBox()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Invite Attendees'), findsOneWidget);
    });

    testWidgets('tap outside dialog (barrier) dismisses it', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildQrSubject(joinCode: 'TPOUT1', qrWidget: const SizedBox()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Invite Attendees'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Invite Attendees'), findsNothing);
    });
  });
}
