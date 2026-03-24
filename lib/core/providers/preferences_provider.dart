import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../constants/app_storage_keys.dart';

/// Provider holding the initialized SharedPreferences instance.
/// Must be overridden in ProviderScope during app startup.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final val = prefs.getString(AppStorageKeys.themeMode);
    if (val == 'light') return ThemeMode.light;
    if (val == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    final val = mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system';
    prefs.setString(AppStorageKeys.themeMode, val);
  }
}

/// Manages the user's preferred theme mode (light, dark, system)
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() => ThemeModeNotifier());

/// Manages whether photo syncing should only happen over Wi-Fi
final wifiSyncModeProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppStorageKeys.wifiSyncEnabled) ?? false;
});

/// Persist wifi sync changes
final wifiSyncPersisterProvider = Provider<void>((ref) {
  final enabled = ref.watch(wifiSyncModeProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  prefs.setBool(AppStorageKeys.wifiSyncEnabled, enabled);
});

/// Stores the ID of the last event the user managed/joined
final lastEventIdProvider = StateProvider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(AppStorageKeys.lastEventId);
});

/// Persist last event changes
final lastEventIdPersisterProvider = Provider<void>((ref) {
  final id = ref.watch(lastEventIdProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  if (id != null) {
    prefs.setString(AppStorageKeys.lastEventId, id);
  } else {
    prefs.remove(AppStorageKeys.lastEventId);
  }
});
