import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:eventshot_mobile/features/events/domain/entities/event.dart';
import 'package:eventshot_mobile/features/events/data/repositories/event_repository_impl.dart';
import 'package:eventshot_mobile/features/events/presentation/providers/event_providers.dart';
import 'package:eventshot_mobile/shared/widgets/dialogs/edit_event_dialog.dart';

final testEvent = Event(
  id: 'evt1',
  name: 'My Event',
  date: DateTime(2026, 6, 15),
  tierId: 'free',
  organizerId: 'org1',
  joinCode: 'ABCDEF',
);

Widget buildEditSubject({required Event event, FakeFirebaseFirestore? firestore}) {
  final fakeFirestore = firestore ?? FakeFirebaseFirestore();
  return ProviderScope(
    overrides: [
      eventRepositoryProvider.overrideWithValue(EventRepositoryImpl(firestore: fakeFirestore)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => EditEventDialog.show(context, event),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('EditEventDialog', () {
    testWidgets('renders with event name pre-filled', (tester) async {
      await tester.pumpWidget(buildEditSubject(event: testEvent));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'My Event'), findsOneWidget);
    });

    testWidgets('shows event date in subtitle', (tester) async {
      await tester.pumpWidget(buildEditSubject(event: testEvent));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Event Date'), findsOneWidget);
      expect(find.textContaining('Jun'), findsOneWidget);
    });

    testWidgets('Cancel button closes dialog', (tester) async {
      await tester.pumpWidget(buildEditSubject(event: testEvent));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsNothing);
    });

    testWidgets('Save button is disabled when name is empty', (tester) async {
      await tester.pumpWidget(buildEditSubject(event: testEvent));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Dialog should remain open since name is empty
      expect(find.text('Edit Event'), findsOneWidget);
    });

    testWidgets('calendar icon is present to open date picker', (tester) async {
      await tester.pumpWidget(buildEditSubject(event: testEvent));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('Save submits and closes dialog on success', (tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      await fakeFirestore.collection('events').doc('evt1').set({
        'id': 'evt1',
        'name': 'My Event',
        'date': DateTime(2026, 6, 15).toIso8601String(),
        'tierId': 'free',
        'organizerId': 'org1',
        'joinCode': 'ABCDEF',
        'attendeeCount': 0,
        'photoCount': 0,
        'maxPhotos': 50,
        'storageBytes': 0,
        'totalSize': 0,
        'qrData': '',
      });

      await tester.pumpWidget(buildEditSubject(event: testEvent, firestore: fakeFirestore));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Updated Event Name');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsNothing);
    });
  });
}
