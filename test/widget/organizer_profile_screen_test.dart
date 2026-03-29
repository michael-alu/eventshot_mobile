import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eventshot_mobile/features/organizer/presentation/organizer_profile_screen.dart';
import '../mocks/firebase_mock.dart';
import 'package:eventshot_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventshot_mobile/core/providers/preferences_provider.dart';

class FakeAuthRepoForProfile implements AuthRepository {
  @override
  Future<Organizer> signInWithEmail({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<Organizer> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'organizer',
  }) =>
      throw UnimplementedError();

  @override
  Future<Organizer?> signInWithGoogle({String role = 'organizer'}) async => null;

  @override
  Future<void> signOut() async {}

  @override
  Stream<Organizer?> watchAuthState() => const Stream.empty();

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> reloadUser() async {}

  @override
  bool get isEmailVerified => false;
}

Widget buildProfileSubjectWithPrefs({Organizer? organizer, required SharedPreferences prefs}) {
  final router = GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(
        path: '/profile',
        builder: (ctx, state) => const OrganizerProfileScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (ctx, state) => const Scaffold(body: Text('Welcome')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepoForProfile()),
      authStateProvider.overrideWith((ref) => Stream.value(organizer)),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('OrganizerProfileScreen', () {
    late SharedPreferences prefs;

    setUpAll(() async {
      setupFirebaseMocks();
      try {
        await Firebase.initializeApp();
      } catch (_) {}
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('shows Profile & Settings heading', (tester) async {
      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
      await tester.pump();

      expect(find.text('Profile & Settings'), findsOneWidget);
    });

    testWidgets('shows default Organizer name when no auth user', (tester) async {
      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Organizer'), findsOneWidget);
    });

    testWidgets('shows organizer display name from authState', (tester) async {
      const organizer = Organizer(id: '1', email: 'test@example.com', displayName: 'Jane Doe');

      await tester.pumpWidget(buildProfileSubjectWithPrefs(organizer: organizer, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('shows PREFERENCES section with Theme Mode', (tester) async {
      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('Theme Mode'), findsOneWidget);
    });

    testWidgets('shows ACCOUNT section with Sign Out', (tester) async {
      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('Sign Out navigates to welcome', (tester) async {
      await tester.pumpWidget(buildProfileSubjectWithPrefs(prefs: prefs));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('shows first letter of display name as avatar initial', (tester) async {
      const organizer = Organizer(id: '1', email: 'a@b.com', displayName: 'Alice');

      await tester.pumpWidget(buildProfileSubjectWithPrefs(organizer: organizer, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('shows email address from organizer', (tester) async {
      const organizer = Organizer(id: '1', email: 'alice@example.com', displayName: 'Alice');

      await tester.pumpWidget(buildProfileSubjectWithPrefs(organizer: organizer, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('alice@example.com'), findsOneWidget);
    });
  });
}
