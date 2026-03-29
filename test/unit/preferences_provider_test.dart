import 'package:eventshot_mobile/core/providers/preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Preferences Notifiers', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeModeNotifier updates theme', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      final notifier = container.read(themeModeProvider.notifier);
      
      expect(container.read(themeModeProvider), ThemeMode.system);
      
      notifier.setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      
      notifier.setThemeMode(ThemeMode.light);
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('WifiSyncMode updates state', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      
      expect(container.read(wifiSyncModeProvider), false);
      
      container.read(wifiSyncModeProvider.notifier).state = true;
      expect(container.read(wifiSyncModeProvider), true);
    });
  });
}
