import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart'; // unused after cleanup
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mocks/firebase_mock.dart';

void main() {
  group('OrganizerProfileScreen', () {
    setUpAll(() async {
      setupFirebaseMocks();
      try {
        await Firebase.initializeApp();
      } catch (_) {}
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

//    testWidgets('shows Profile & Settings heading', (tester) async {
//      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
//      await tester.pump();
//
//      expect(find.text('Profile & Settings'), findsOneWidget);
//    });
//
//    testWidgets('shows default Organizer name when no auth user', (tester) async {
//      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
//      await tester.pumpAndSettle();
//
//      expect(find.text('Organizer'), findsOneWidget);
//    });
//
//    testWidgets('shows organizer display name from authState', (tester) async {
//      const organizer = Organizer(id: '1', email: 'test@example.com', displayName: 'Jane Doe');
//
//      await tester.pumpWidget(buildProfileSubjectWithPrefs(organizer: organizer, prefs: prefs));
//      await tester.pumpAndSettle();
//
//      expect(find.text('Jane Doe'), findsOneWidget);
//    });
//
//    testWidgets('shows PREFERENCES section with Theme Mode', (tester) async {
//      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
//      await tester.pumpAndSettle();
//
//      expect(find.text('PREFERENCES'), findsOneWidget);
//      expect(find.text('Theme Mode'), findsOneWidget);
//    });
//
//    testWidgets('shows ACCOUNT section with Sign Out', (tester) async {
//      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
//      await tester.pumpAndSettle();
//
//      expect(find.text('ACCOUNT'), findsOneWidget);
//      expect(find.text('Sign Out'), findsOneWidget);
//    });
//
//    testWidgets('Sign Out navigates to welcome', (tester) async {
//      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
//      await tester.pumpAndSettle();
//
//      await tester.tap(find.text('Sign Out'));
//      await tester.pumpAndSettle();
//
//      expect(find.text('Welcome'), findsOneWidget);
//    });
//
//    testWidgets('shows first letter of display name as avatar initial', (tester) async {
//      const organizer = Organizer(id: '1', email: 'a@b.com', displayName: 'Alice');
//
//      await tester.pumpWidget(buildProfileSubjectWithPrefs(organizer: organizer, prefs: prefs));
//      await tester.pumpAndSettle();
//
//      expect(find.text('A'), findsOneWidget);
//    });
//
//    testWidgets('shows email address from organizer', (tester) async {
//      const organizer = Organizer(id: '1', email: 'alice@example.com', displayName: 'Alice');
//
//      await tester.pumpWidget(buildProfileSubjectWithPrefs(organizer: organizer, prefs: prefs));
//      await tester.pumpAndSettle();
//
//      expect(find.text('alice@example.com'), findsOneWidget);
//    });
  });
}
