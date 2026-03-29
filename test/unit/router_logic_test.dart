import 'package:eventshot_mobile/core/router/app_router.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter.redirectLogic Unit Tests', () {
    test('returns null if auth is loading', () {
      final result = AppRouter.redirectLogic(
        matchedLocation: '/some-path',
        authState: const AsyncValue<Organizer?>.loading(),
      );
      expect(result, isNull);
    });

    test('redirects from /organizer to /organizer/dashboard', () {
      final result = AppRouter.redirectLogic(
        matchedLocation: '/organizer',
        authState: const AsyncValue.data(null),
      );
      expect(result, AppRouter.organizerDashboard);
    });

    test('redirects to welcome if guest tries to access organizer flow', () {
      final result = AppRouter.redirectLogic(
        matchedLocation: '/organizer/dashboard',
        authState: const AsyncValue.data(null),
      );
      expect(result, AppRouter.welcome);
    });

    test('redirects to dashboard if logged in user hits welcome', () {
      const user = Organizer(id: '1', email: 'a@b.com', displayName: 'D', role: 'organizer');
      final result = AppRouter.redirectLogic(
        matchedLocation: AppRouter.welcome,
        authState: const AsyncValue.data(user),
      );
      expect(result, AppRouter.organizerDashboard);
    });

    test('redirects to user dashboard if attendee hits welcome', () {
      const user = Organizer(id: '2', email: 'b@b.com', displayName: 'A', role: 'attendee');
      final result = AppRouter.redirectLogic(
        matchedLocation: AppRouter.welcome,
        authState: const AsyncValue.data(user),
      );
      expect(result, AppRouter.userDashboard);
    });
  });
}
