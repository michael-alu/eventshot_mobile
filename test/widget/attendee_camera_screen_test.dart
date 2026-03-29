import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:eventshot_mobile/core/router/app_router.dart';
import 'package:eventshot_mobile/features/attendee/presentation/attendee_camera_screen.dart';
import 'package:eventshot_mobile/features/attendee/presentation/providers/attendee_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import '../mocks/camera_mock.dart';
import '../mocks/firebase_mock.dart';

class MockAttendeeSessionNotifier extends AttendeeSessionNotifier {
  final AttendeeSession initialSession;
  MockAttendeeSessionNotifier(this.initialSession);

  @override
  AttendeeSession build() => initialSession;
}

void main() {
  late MockCameraPlatform mockCameraPlatform;

  setUp(() async {
    setupFirebaseMocks();
    await Firebase.initializeApp();
    mockCameraPlatform = MockCameraPlatform();
    CameraPlatform.instance = mockCameraPlatform;
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AttendeeCameraScreen(),
        ),
        GoRoute(
          path: AppRouter.photoReview,
          builder: (context, state) => const Scaffold(body: Text('Photo Review')),
        ),
        GoRoute(
          path: '/gallery/:id',
          builder: (context, state) => Scaffold(body: Text('Gallery ${state.pathParameters['id']}')),
        ),
        GoRoute(
          path: AppRouter.welcome,
          builder: (context, state) => const Scaffold(body: Text('Welcome')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        attendeeSessionProvider.overrideWith(
          () => MockAttendeeSessionNotifier(
            const AttendeeSession(
              eventId: 'test-event-id',
              eventName: 'Test Event',
              photoLimit: 50,
              photosTaken: 10,
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('AttendeeCameraScreen shows loading then camera preview', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Initially should show loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for camera initialization
    await tester.pumpAndSettle();

    // Now it should show camera preview (mocked)
    // Note: CameraPreview is a widget from the camera package
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('AttendeeCameraScreen shows correct photos remaining', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Photos Remaining'), findsOneWidget);
    expect(find.textContaining('40'), findsOneWidget); // 50 - 10 = 40
  });

  testWidgets('Tapping flash button toggles flash state', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final flashButton = find.byIcon(Icons.flash_off);
    expect(flashButton, findsOneWidget);

    await tester.tap(flashButton);
    await tester.pump();

    expect(find.byIcon(Icons.flash_on), findsOneWidget);
  });

  testWidgets('Tapping capture button takes picture and navigates', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Better: find by the white container
    final whiteContainer = find.descendant(
      of: find.byType(GestureDetector),
      matching: find.byWidgetPredicate((widget) => widget is Container && widget.decoration is BoxDecoration && (widget.decoration as BoxDecoration).color == Colors.white),
    );

    await tester.tap(whiteContainer);
    await tester.pumpAndSettle();

    expect(find.text('Photo Review'), findsOneWidget);
  });

  testWidgets('Tapping gallery button navigates to gallery', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Gallery button is the last one in bottom controls
    final galleryButton = find.byIcon(Icons.person);
    await tester.tap(galleryButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Gallery test-event-id'), findsOneWidget);
  });

  testWidgets('Tapping close button navigates back/welcome', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final closeButton = find.byIcon(Icons.close);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
  });
}
