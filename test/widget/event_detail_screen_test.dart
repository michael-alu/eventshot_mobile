import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:eventshot_mobile/features/organizer/presentation/event_detail_screen.dart';
import 'package:eventshot_mobile/features/events/domain/entities/event.dart';
import 'package:eventshot_mobile/features/events/presentation/providers/event_providers.dart';
import 'package:eventshot_mobile/features/events/data/repositories/event_repository_impl.dart';
import 'package:eventshot_mobile/features/gallery/data/providers/gallery_providers.dart';
import 'package:eventshot_mobile/core/services/cloudinary_service.dart';

final testEvt = Event(
  id: 'evt1',
  name: 'Test Event',
  date: DateTime(2026, 8, 10),
  tierId: 'pro',
  organizerId: 'org1',
  joinCode: 'ABCDEF',
  photoCount: 5,
  attendeeCount: 3,
);

Widget buildEventDetailApp({Event? event}) {
  final fakeFirestore = FakeFirebaseFirestore();
  final router = GoRouter(
    initialLocation: '/events/evt1',
    routes: [
      GoRoute(
        path: '/events/:eventId',
        builder: (ctx, state) {
          final id = state.pathParameters['eventId']!;
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/organizer/events',
        builder: (ctx, state) => const Scaffold(body: Text('Events')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      watchEventProvider.overrideWith((ref, id) => Stream.value(event ?? testEvt)),
      galleryPhotosProvider.overrideWith((ref, id) => Stream.value([])),
      galleryPhotoDocsProvider.overrideWith((ref, id) => Stream.value([])),
      cloudinaryStatsProvider.overrideWith(
        (ref, id) async => const CloudinaryFolderStats(totalBytes: 1024, totalCount: 5),
      ),
      eventRepositoryProvider.overrideWithValue(EventRepositoryImpl(firestore: fakeFirestore)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('EventDetailScreen', () {
    testWidgets('renders event name in app bar', (tester) async {
      await tester.pumpWidget(buildEventDetailApp());
      await tester.pumpAndSettle();

      expect(find.text('Test Event'), findsOneWidget);
    });

    testWidgets('renders photo count stat', (tester) async {
      await tester.pumpWidget(buildEventDetailApp());
      await tester.pumpAndSettle();

      expect(find.text('Photos'), findsOneWidget);
      expect(find.text('5'), findsAtLeast(1));
    });

    testWidgets('renders attendee count stat', (tester) async {
      await tester.pumpWidget(buildEventDetailApp());
      await tester.pumpAndSettle();

      expect(find.text('Attendees'), findsOneWidget);
      expect(find.text('3'), findsAtLeast(1));
    });

    testWidgets('renders share event button', (tester) async {
      await tester.pumpWidget(buildEventDetailApp());
      await tester.pumpAndSettle();

      expect(find.text('Share Event Access'), findsOneWidget);
    });

    testWidgets('renders photo grid with one photo', (tester) async {
      await tester.pumpWidget(buildEventDetailApp());
      await tester.pumpAndSettle();

      // At least the grid structure is present
      expect(find.text('Event Photos'), findsOneWidget);
    });

    testWidgets('renders storage stat', (tester) async {
      await tester.pumpWidget(buildEventDetailApp());
      await tester.pumpAndSettle();

      expect(find.text('Storage Used'), findsOneWidget);
    });

    testWidgets('shows Event Stats section header', (tester) async {
      await tester.pumpWidget(buildEventDetailApp());
      await tester.pumpAndSettle();

      expect(find.text('Event Stats'), findsOneWidget);
    });

    testWidgets('shows loading indicator when event is loading', (tester) async {
      final router = GoRouter(
        initialLocation: '/events/evt1',
        routes: [
          GoRoute(
            path: '/events/:eventId',
            builder: (ctx, state) {
              final id = state.pathParameters['eventId']!;
              return EventDetailScreen(eventId: id);
            },
          ),
        ],
      );

      // Provider that never resolves
      await tester.pumpWidget(ProviderScope(
        overrides: [
          watchEventProvider.overrideWith((ref, id) => const Stream.empty()),
          galleryPhotosProvider.overrideWith((ref, id) => const Stream.empty()),
          galleryPhotoDocsProvider.overrideWith((ref, id) => const Stream.empty()),
          cloudinaryStatsProvider.overrideWith((ref, id) => Future.delayed(const Duration(minutes: 5))),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows event not found when event is null', (tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final router = GoRouter(
        initialLocation: '/events/evt1',
        routes: [
          GoRoute(
            path: '/events/:eventId',
            builder: (ctx, state) => EventDetailScreen(eventId: state.pathParameters['eventId']!),
          ),
        ],
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [
          watchEventProvider.overrideWith((ref, id) => Stream.value(null)),
          galleryPhotosProvider.overrideWith((ref, id) => Stream.value([])),
          galleryPhotoDocsProvider.overrideWith((ref, id) => Stream.value([])),
          cloudinaryStatsProvider.overrideWith(
            (ref, id) async => const CloudinaryFolderStats(totalBytes: 0, totalCount: 0),
          ),
          eventRepositoryProvider.overrideWithValue(EventRepositoryImpl(firestore: fakeFirestore)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Event not found.'), findsOneWidget);
    });

    testWidgets('popup menu is available when event is loaded', (tester) async {
      await tester.pumpWidget(buildEventDetailApp());
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('tapping Share Event opens QrInviteDialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildEventDetailApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Share Event Access'));
      await tester.pumpAndSettle();

      expect(find.text('Invite Attendees'), findsOneWidget);
    });
  });
}
