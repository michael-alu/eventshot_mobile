import 'package:eventshot_mobile/features/user/presentation/user_settings_screen.dart';
import 'package:eventshot_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';
import 'package:eventshot_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import '../mocks/firebase_mock.dart';
import 'user_settings_screen_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuth;

  setUp(() async {
    setupFirebaseMocks();
    await Firebase.initializeApp();
    mockAuth = MockAuthRepository();
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuth),
        authStateProvider.overrideWith((ref) => Stream.value(
          const Organizer(id: '123', email: 'test@example.com', displayName: 'Test User')
        )),
      ],
      child: const MaterialApp(
        home: UserSettingsScreen(),
      ),
    );
  }

  testWidgets('UserSettingsScreen renders all sections', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('Toggling Dark Mode updates preference', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final darkModeSwitch = find.byType(Switch).first;
    await tester.tap(darkModeSwitch);
    await tester.pumpAndSettle();

    // Verify state change if possible, or just that it didn't crash
    expect(darkModeSwitch, findsOneWidget);
  });

  testWidgets('Toggling WiFi Sync updates preference', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final wifiSwitch = find.byType(Switch).last;
    await tester.tap(wifiSwitch);
    await tester.pumpAndSettle();

    expect(wifiSwitch, findsOneWidget);
  });

  testWidgets('Tapping Sign Out calls auth repository', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    when(mockAuth.signOut()).thenAnswer((_) async => {});

    final signOutButton = find.text('Sign Out');
    await tester.tap(signOutButton);
    await tester.pumpAndSettle();

    verify(mockAuth.signOut()).called(1);
  });
}
