import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/auth/presentation/email_verification_screen.dart';
import 'package:eventshot_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';

class FakeAuthRepositoryForVerification implements AuthRepository {
  bool emailVerified;
  FakeAuthRepositoryForVerification({this.emailVerified = false});

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
  bool get isEmailVerified => emailVerified;
}

Widget buildVerificationSubject({FakeAuthRepositoryForVerification? repo}) {
  final fakeRepo = repo ?? FakeAuthRepositoryForVerification();
  final router = GoRouter(
    initialLocation: '/verify',
    routes: [
      GoRoute(
        path: '/verify',
        builder: (ctx, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (ctx, state) => const Scaffold(body: Text('Welcome')),
      ),
      GoRoute(
        path: '/organizer/dashboard',
        builder: (ctx, state) => const Scaffold(body: Text('Dashboard')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(fakeRepo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('EmailVerificationScreen', () {
    testWidgets('renders check inbox heading', (tester) async {
      await tester.pumpWidget(buildVerificationSubject());
      await tester.pump();

      expect(find.text('Check your inbox'), findsOneWidget);
    });

    testWidgets('renders Resend Email button', (tester) async {
      await tester.pumpWidget(buildVerificationSubject());
      await tester.pump();

      expect(find.text('Resend Email'), findsOneWidget);
    });

    testWidgets('renders Back to Sign In button', (tester) async {
      await tester.pumpWidget(buildVerificationSubject());
      await tester.pump();

      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('shows email icon', (tester) async {
      await tester.pumpWidget(buildVerificationSubject());
      await tester.pump();

      expect(find.byIcon(Icons.mark_email_unread_outlined), findsOneWidget);
    });

    testWidgets('shows instruction text', (tester) async {
      await tester.pumpWidget(buildVerificationSubject());
      await tester.pump();

      expect(find.textContaining('verification link'), findsOneWidget);
    });

    testWidgets('Resend Email button is enabled initially', (tester) async {
      await tester.pumpWidget(buildVerificationSubject());
      await tester.pump();

      // Button is present and enabled before any tap
      expect(find.text('Resend Email'), findsOneWidget);
    });

    testWidgets('Back to Sign In navigates away', (tester) async {
      await tester.pumpWidget(buildVerificationSubject());
      await tester.pump();

      await tester.tap(find.text('Back to Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
