// Tests for the submit/form-action logic paths in auth screens
// (success, error, and role-redirect branches).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/auth/presentation/organizer_login_screen.dart';
import 'package:eventshot_mobile/features/auth/presentation/organizer_signup_screen.dart';
import 'package:eventshot_mobile/features/auth/presentation/attendee_login_screen.dart';
import 'package:eventshot_mobile/features/auth/presentation/attendee_signup_screen.dart';
import 'package:eventshot_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventshot_mobile/shared/widgets/buttons/primary_button.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void useLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ---------------------------------------------------------------------------
// Stub helpers
// ---------------------------------------------------------------------------

class _Stub extends StatelessWidget {
  final String label;
  const _Stub({required this.label});
  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}

class SuccessOrganizerRepo implements AuthRepository {
  final String role;
  SuccessOrganizerRepo({this.role = 'organizer'});

  @override
  Future<Organizer> signInWithEmail({required String email, required String password}) async =>
      Organizer(id: '1', email: email, displayName: 'Test', role: role);

  @override
  Future<Organizer> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'organizer',
  }) async =>
      Organizer(id: '1', email: email, displayName: displayName, role: role);

  @override
  Future<Organizer?> signInWithGoogle({String role = 'organizer'}) async =>
      Organizer(id: '1', email: 'g@g.com', displayName: 'Google', role: role);

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

class ErrorAuthRepo implements AuthRepository {
  @override
  Future<Organizer> signInWithEmail({required String email, required String password}) =>
      Future.error(Exception('Invalid credentials'));

  @override
  Future<Organizer> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'organizer',
  }) =>
      Future.error(Exception('Sign-up failed'));

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

// ---------------------------------------------------------------------------
// Router builders
// ---------------------------------------------------------------------------

Widget buildOrganizerLoginApp(AuthRepository repo) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (ctx, st) => const OrganizerLoginScreen()),
      GoRoute(path: '/auth/organizer-signup', builder: (ctx, st) => const _Stub(label: 'Signup')),
      GoRoute(path: '/auth/forgot-password', builder: (ctx, st) => const _Stub(label: 'Forgot')),
      GoRoute(path: '/organizer/dashboard', builder: (ctx, st) => const _Stub(label: 'Dashboard')),
      GoRoute(path: '/auth/attendee-login', builder: (ctx, st) => const _Stub(label: 'AttendeeLogin')),
    ],
  );
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(routerConfig: router),
  );
}

Widget buildOrganizerSignupApp(AuthRepository repo) {
  final router = GoRouter(
    initialLocation: '/signup',
    routes: [
      GoRoute(path: '/signup', builder: (ctx, st) => const OrganizerSignUpScreen()),
      GoRoute(path: '/auth/organizer-login', builder: (ctx, st) => const _Stub(label: 'Login')),
      // AppRouter.emailVerification = '/auth/verify-email'
      GoRoute(path: '/auth/verify-email', builder: (ctx, st) => const _Stub(label: 'Verify')),
      GoRoute(path: '/organizer/dashboard', builder: (ctx, st) => const _Stub(label: 'Dashboard')),
      GoRoute(path: '/auth/attendee-login', builder: (ctx, st) => const _Stub(label: 'AttendeeLogin')),
    ],
  );
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(routerConfig: router),
  );
}

Widget buildAttendeeLoginApp(AuthRepository repo) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (ctx, st) => const AttendeeLoginScreen()),
      GoRoute(path: '/auth/attendee-signup', builder: (ctx, st) => const _Stub(label: 'Signup')),
      // AttendeeLoginScreen navigates to /welcome on success
      GoRoute(path: '/welcome', builder: (ctx, st) => const _Stub(label: 'Welcome')),
      GoRoute(path: '/auth/organizer-login', builder: (ctx, st) => const _Stub(label: 'OrgLogin')),
      GoRoute(path: '/auth/forgot-password', builder: (ctx, st) => const _Stub(label: 'Forgot')),
    ],
  );
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(routerConfig: router),
  );
}

Widget buildAttendeeSignupApp(AuthRepository repo) {
  final router = GoRouter(
    initialLocation: '/signup',
    routes: [
      GoRoute(path: '/signup', builder: (ctx, st) => const AttendeeSignUpScreen()),
      GoRoute(path: '/auth/attendee-login', builder: (ctx, st) => const _Stub(label: 'Login')),
      // AttendeeSignUpScreen navigates to /auth/verify-email on success
      GoRoute(path: '/auth/verify-email', builder: (ctx, st) => const _Stub(label: 'Verify')),
      GoRoute(path: '/welcome', builder: (ctx, st) => const _Stub(label: 'Welcome')),
    ],
  );
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// OrganizerLoginScreen submit flows
// ---------------------------------------------------------------------------

void main() {
  group('OrganizerLoginScreen - submit', () {
    testWidgets('successful login navigates to organizer dashboard', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildOrganizerLoginApp(SuccessOrganizerRepo()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('login error shows snackbar', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildOrganizerLoginApp(ErrorAuthRepo()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'bad@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });

    testWidgets('login as attendee role redirects to attendee login', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildOrganizerLoginApp(SuccessOrganizerRepo(role: 'attendee')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'att@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'pass123');
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pumpAndSettle();

      expect(find.text('AttendeeLogin'), findsOneWidget);
    });
  });

  group('OrganizerSignUpScreen - submit', () {
    testWidgets('successful signup navigates to verify email', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildOrganizerSignupApp(SuccessOrganizerRepo()));
      await tester.pumpAndSettle();

      // 3 fields: name, email, password
      await tester.enterText(find.byType(TextFormField).at(0), 'New User');
      await tester.enterText(find.byType(TextFormField).at(1), 'new@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('signup error shows snackbar', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildOrganizerSignupApp(ErrorAuthRepo()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Bad User');
      await tester.enterText(find.byType(TextFormField).at(1), 'bad@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Sign-up failed'), findsOneWidget);
    });
  });

  group('AttendeeLoginScreen - submit', () {
    testWidgets('successful attendee login navigates to welcome', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildAttendeeLoginApp(SuccessOrganizerRepo(role: 'attendee')));
      await tester.pumpAndSettle();

      // 2 fields: email, password. Submit button is OutlinedButton 'Log In with Email'
      await tester.enterText(find.byType(TextFormField).at(0), 'att@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'pass123');
      await tester.tap(find.text('Log In with Email'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('attendee login error shows snackbar', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildAttendeeLoginApp(ErrorAuthRepo()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'bad@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
      await tester.tap(find.text('Log In with Email'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });
  });

  group('AttendeeSignUpScreen - submit', () {
    testWidgets('successful attendee signup navigates to verify', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildAttendeeSignupApp(SuccessOrganizerRepo(role: 'attendee')));
      await tester.pumpAndSettle();

      // 3 fields: name, email, password
      await tester.enterText(find.byType(TextFormField).at(0), 'New Att');
      await tester.enterText(find.byType(TextFormField).at(1), 'att@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.text('Sign Up with Email'));
      await tester.pumpAndSettle();

      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('attendee signup error shows snackbar', (tester) async {
      useLargeViewport(tester);
      await tester.pumpWidget(buildAttendeeSignupApp(ErrorAuthRepo()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Bad Att');
      await tester.enterText(find.byType(TextFormField).at(1), 'bad@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.text('Sign Up with Email'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sign-up failed'), findsOneWidget);
    });
  });
}
