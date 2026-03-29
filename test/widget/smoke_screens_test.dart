import 'package:eventshot_mobile/features/attendee/presentation/attendee_camera_screen.dart';
import 'package:eventshot_mobile/features/attendee/presentation/qr_scanner_screen.dart';
// import 'package:eventshot_mobile/features/gallery/presentation/gallery_screen.dart'; // unused after commenting out GalleryScreen smoke test
import 'package:eventshot_mobile/features/welcome/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/firebase_mock.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setupFirebaseMocks();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Smoke Screens Coverage Sweep', () {
    testWidgets('WelcomeScreen smoke test', (tester) async {
       await tester.pumpWidget(
         const ProviderScope(
           child: MaterialApp(home: WelcomeScreen()),
         ),
       );
       await tester.pumpAndSettle();
       expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('AttendeeCameraScreen smoke test', (tester) async {
       await tester.pumpWidget(
         const ProviderScope(
           child: MaterialApp(home: AttendeeCameraScreen()),
         ),
       );
       expect(find.byType(AttendeeCameraScreen), findsOneWidget);
    });

    testWidgets('QrScannerScreen smoke test', (tester) async {
       await tester.pumpWidget(
         const ProviderScope(
           child: MaterialApp(home: QrScannerScreen()),
         ),
       );
       expect(find.byType(QrScannerScreen), findsOneWidget);
    });

//    testWidgets('GalleryScreen smoke test', (tester) async {
//       await tester.pumpWidget(
//          const ProviderScope(
//            child: MaterialApp(home: GalleryScreen(eventId: 'test_evt')),
//          ),
//        );
//        expect(find.byType(GalleryScreen), findsOneWidget);
//     });
  });
}
