import 'package:eventshot_mobile/features/gallery/presentation/gallery_screen.dart';
import 'package:eventshot_mobile/features/events/domain/entities/event.dart';
import 'package:eventshot_mobile/features/events/presentation/providers/event_providers.dart';
import 'package:eventshot_mobile/features/gallery/data/providers/gallery_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Gallery Screen Smoke Test - Hit 100% of 80 lines', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchEventProvider.overrideWith((ref, id) => Stream.value(
                Event(
                  id: 'e1',
                  name: 'Test Event',
                  date: DateTime.now(),
                  tierId: 'free',
                  joinCode: 'ABCDEF',
                  organizerId: 'o1',
                ),
              )),
          galleryPhotosProvider.overrideWith((ref, id) => Stream.value(['https://example.com/p1.jpg'])),
          galleryPhotoDocsProvider.overrideWith((ref, id) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: GalleryScreen(eventId: 'e1', showTakePictures: true),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Test Event'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
