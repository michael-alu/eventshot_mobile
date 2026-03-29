import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mocks/firebase_mock.dart';

void main() {
  setUp(() async {
    setupFirebaseMocks();
    await Firebase.initializeApp();
    SharedPreferences.setMockInitialValues({});
  });
/*
  Widget createWidgetUnderTest() { ... }
*/

//  testWidgets('UserSettingsScreen renders all sections', (tester) async {
//    await tester.pumpWidget(createWidgetUnderTest());
//    await tester.pumpAndSettle();
//
//    expect(find.text('Settings'), findsOneWidget);
//    expect(find.text('Preferences'), findsOneWidget);
//    expect(find.text('Account'), findsOneWidget);
//    expect(find.text('Sign Out'), findsOneWidget);
//  });
//
//  testWidgets('Toggling Dark Mode updates preference', (tester) async {
//    await tester.pumpWidget(createWidgetUnderTest());
//    await tester.pumpAndSettle();
//
//    final darkModeSwitch = find.byType(Switch).first;
//    await tester.tap(darkModeSwitch);
//    await tester.pumpAndSettle();
//
//    // Verify state change if possible, or just that it didn't crash
//    expect(darkModeSwitch, findsOneWidget);
//  });
//
//  testWidgets('Toggling WiFi Sync updates preference', (tester) async {
//    await tester.pumpWidget(createWidgetUnderTest());
//    await tester.pumpAndSettle();
//
//    final wifiSwitch = find.byType(Switch).last;
//    await tester.tap(wifiSwitch);
//    await tester.pumpAndSettle();
//
//    expect(wifiSwitch, findsOneWidget);
//  });
//
//  testWidgets('Tapping Sign Out calls auth repository', (tester) async {
//    await tester.pumpWidget(createWidgetUnderTest());
//    await tester.pumpAndSettle();
//
//    when(mockAuth.signOut()).thenAnswer((_) async => {});
//
//    final signOutButton = find.text('Sign Out');
//    await tester.tap(signOutButton);
//    await tester.pumpAndSettle();
//
//    verify(mockAuth.signOut()).called(1);
//  });
}
