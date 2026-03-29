import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/auth/presentation/attendee_login_screen.dart';
import 'package:eventshot_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<Organizer> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'organizer',
  }) => throw UnimplementedError();

  @override
  Future<Organizer> signInWithEmail({required String email, required String password}) =>
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

Widget _buildSubject() {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const AttendeeLoginScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const _Stub()),
      GoRoute(path: '/auth/attendee-signup', builder: (_, _) => const _Stub()),
      GoRoute(path: '/auth/forgot-password', builder: (_, _) => const _Stub()),
    ],
  );

  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(_FakeAuthRepo())],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('AttendeeLoginScreen', () {
    testWidgets('renders Welcome Back heading', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('renders Continue with Google button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('renders OR CONTINUE WITH EMAIL divider', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('OR CONTINUE WITH EMAIL'), findsOneWidget);
    });

    testWidgets('renders Email field', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders Password field', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Log In with Email button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Log In with Email'), findsOneWidget);
    });

    testWidgets('renders Forgot Password link', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('shows validation errors when email submit with empty fields', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Log In with Email'));
      await tester.tap(find.text('Log In with Email'));
      await tester.pump();
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('visibility toggle works on password field', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
