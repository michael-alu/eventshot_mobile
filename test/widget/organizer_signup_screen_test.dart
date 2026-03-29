import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eventshot_mobile/features/auth/presentation/organizer_signup_screen.dart';
import 'package:eventshot_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventshot_mobile/shared/widgets/buttons/primary_button.dart';

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
    initialLocation: '/signup',
    routes: [
      GoRoute(path: '/signup', builder: (_, _) => const OrganizerSignUpScreen()),
      GoRoute(path: '/auth/organizer-login', builder: (_, _) => const _Stub()),
      GoRoute(path: '/auth/email-verification', builder: (_, _) => const _Stub()),
      GoRoute(path: '/organizer/dashboard', builder: (_, _) => const _Stub()),
      GoRoute(path: '/auth/attendee-login', builder: (_, _) => const _Stub()),
    ],
  );

  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(_FakeAuthRepo())],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('OrganizerSignUpScreen', () {
    testWidgets('renders Create Organizer Account heading', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Create Organizer Account'), findsOneWidget);
    });

    testWidgets('renders Full Name field', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('renders Email Address field', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('renders Password field', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Get Started button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('shows validation errors when submitted empty', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('shows email validation error for invalid email', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      // Fill name but enter bad email
      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'bademail');
      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('visibility toggle on password field works', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('renders OR CONTINUE WITH section', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('OR CONTINUE WITH'), findsOneWidget);
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
