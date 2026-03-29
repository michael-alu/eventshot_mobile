import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/auth/presentation/attendee_signup_screen.dart';
import 'package:eventshot_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<Organizer> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'attendee',
  }) => throw UnimplementedError();

  @override
  Future<Organizer> signInWithEmail({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<Organizer?> signInWithGoogle({String role = 'attendee'}) async => null;

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
    initialLocation: '/signup',
    routes: [
      GoRoute(path: '/signup', builder: (_, _) => const AttendeeSignUpScreen()),
      GoRoute(path: '/auth/attendee-login', builder: (_, _) => const _Stub()),
      GoRoute(path: '/auth/email-verification', builder: (_, _) => const _Stub()),
      GoRoute(path: '/welcome', builder: (_, _) => const _Stub()),
    ],
  );

  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(_FakeAuthRepo())],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('AttendeeSignUpScreen', () {
    testWidgets('renders Join EventShot heading', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Join EventShot'), findsOneWidget);
    });

    testWidgets('renders Continue with Google button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('renders OR CONTINUE WITH EMAIL section', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('OR CONTINUE WITH EMAIL'), findsOneWidget);
    });

    testWidgets('renders form fields', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitted empty', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sign Up with Email'));
      await tester.tap(find.text('Sign Up with Email'));
      await tester.pump();
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('visibility toggle works on password field', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      await tester.ensureVisible(find.byIcon(Icons.visibility));
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
