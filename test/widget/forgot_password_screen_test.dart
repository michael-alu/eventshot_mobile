import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:eventshot_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';

class FakeAuthRepositoryForReset implements AuthRepository {
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

Widget buildForgotSubject() {
  final router = GoRouter(
    initialLocation: '/forgot',
    routes: [
      GoRoute(
        path: '/forgot',
        builder: (ctx, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/organizer-login',
        builder: (ctx, state) => const Scaffold(body: Text('Login')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepositoryForReset()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('ForgotPasswordScreen', () {
    testWidgets('renders form with email field', (tester) async {
      await tester.pumpWidget(buildForgotSubject());
      await tester.pump();

      expect(find.text('Forgot your password?'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('renders lock reset icon', (tester) async {
      await tester.pumpWidget(buildForgotSubject());
      await tester.pump();

      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(buildForgotSubject());
      await tester.pump();

      expect(find.textContaining("we'll send you a link"), findsOneWidget);
    });

    testWidgets('Back to Log In button navigates away', (tester) async {
      await tester.pumpWidget(buildForgotSubject());
      await tester.pump();

      await tester.tap(find.text('Back to Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('submit with invalid email does not call repo', (tester) async {
      await tester.pumpWidget(buildForgotSubject());
      await tester.pump();

      // tap with empty field
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      // Still on form, no success screen
      expect(find.text('Forgot your password?'), findsOneWidget);
    });

    testWidgets('submit with valid email shows success screen', (tester) async {
      await tester.pumpWidget(buildForgotSubject());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
      await tester.pump();

      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget);
    });

    testWidgets('success screen Back to Log In navigates away', (tester) async {
      await tester.pumpWidget(buildForgotSubject());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
      await tester.pump();
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back to Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}
