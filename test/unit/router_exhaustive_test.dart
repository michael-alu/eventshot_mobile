import 'package:eventshot_mobile/core/router/app_router.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Router Redirect Exhaustive Coverage - Logic Sweep', () {
    test('Hits all redirect logic branches', () {
      const org = Organizer(id: '1', email: 'e', displayName: 'd', role: 'organizer');
      const att = Organizer(id: '2', email: 'e2', displayName: 'd2', role: 'attendee');
      
      final scenarios = [
        // [Location, AuthState, ExpectedResult]
        ['/organizer', const AsyncValue.data(null), AppRouter.organizerDashboard],
        ['/organizer', const AsyncValue.data(org), AppRouter.organizerDashboard],
        ['/organizer/events', const AsyncValue.data(null), AppRouter.welcome],
        ['/user/dashboard', const AsyncValue.data(null), AppRouter.welcome],
        ['/welcome', const AsyncValue.data(org), AppRouter.organizerDashboard],
        ['/welcome', const AsyncValue.data(att), AppRouter.userDashboard],
        ['/organizer/dashboard', const AsyncValue.data(att), AppRouter.userDashboard],
        ['/user/settings', const AsyncValue.data(org), AppRouter.organizerDashboard],
      ];

      for (final scenario in scenarios) {
        final loc = scenario[0] as String;
        final auth = scenario[1] as AsyncValue<Organizer?>;
        final expected = scenario[2] as String?;
        
        final result = AppRouter.redirectLogic(
          matchedLocation: loc,
          authState: auth,
        );
        expect(result, expected, reason: 'Failed for loc: $loc with auth: $auth');
      }
    });

    test('Auth loading branch', () {
      final result = AppRouter.redirectLogic(
        matchedLocation: '/welcome',
        authState: const AsyncValue<Organizer?>.loading(),
      );
      expect(result, isNull);
    });
  });
}
