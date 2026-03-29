import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eventshot_mobile/features/attendee/presentation/manual_code_entry_screen.dart';
import 'package:eventshot_mobile/features/attendee/data/repositories/attendee_repository.dart';
import 'package:eventshot_mobile/features/events/domain/entities/event.dart';

class _FakeAttendeeRepo implements AttendeeRepository {
  @override
  Future<Event?> validateJoinCode(String code) async {
    if (code == '123456') {
      return Event(id: 'EVT1', name: 'Test Event', joinCode: '123456', organizerId: 'org1', date: DateTime.now(), tierId: 'pro');
    }
    return null;
  }
  
  @override
  Future<int> assertUploadLimit(String eventId) async {
    return 0;
  }

  @override
  Future<void> executeOfflineUpload(String eventId, dynamic photoFile) async {}
}

Widget _buildSubject() {
  final router = GoRouter(
    initialLocation: '/manual',
    routes: [
      GoRoute(path: '/manual', builder: (_, _) => const ManualCodeEntryScreen()),
      GoRoute(path: '/attendee/camera', builder: (_, _) => const _Stub()),
    ],
  );

  return ProviderScope(
    overrides: [
      attendeeRepositoryProvider.overrideWithValue(_FakeAttendeeRepo()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ManualCodeEntryScreen', () {
    testWidgets('renders screen elements', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Join Event'), findsWidgets);
      expect(find.text('Manual Code Entry'), findsOneWidget);
    });

    testWidgets('shows invalid code message on wrong code', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      // Find the TextField and enter wrong code
      await tester.enterText(find.byType(TextField).first, '111111');
      await tester.pump();
      // Tap join
      // Wait, ConfirmationCodeField has 6 fields usually. We might just tap "Join Event" 
      // Button is disabled until 6 chars are typed. We can verify disabled state by attempting tap.
      await tester.tap(find.text('Join Event').last);
      await tester.pump(); // Let error show
      
      expect(find.text('Invalid join code. Please try again.'), findsOneWidget);
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
