import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eventshot_mobile/features/checkout/presentation/checkout_screen.dart';

Widget _buildSubject(String eventId) {
  final router = GoRouter(
    initialLocation: '/checkout',
    routes: [
      GoRoute(path: '/checkout', builder: (_, _) => CheckoutScreen(eventId: eventId)),
      GoRoute(path: '/organizer/dashboard', builder: (_, _) => const _Stub()),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CheckoutScreen', () {
    testWidgets('renders screen elements', (tester) async {
      await tester.pumpWidget(_buildSubject('evt1'));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Payment Details'), findsOneWidget);
      expect(find.text('Pay & Create QR'), findsOneWidget);
    });

    testWidgets('allows text input into payment fields', (tester) async {
      await tester.pumpWidget(_buildSubject('evt1'));
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextField, 'John Doe');
      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'Alice');
      expect(find.text('Alice'), findsOneWidget);
    });
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
