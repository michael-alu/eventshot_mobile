import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider holding the initialized SharedPreferences instance.
/// Must be overridden in ProviderScope during app startup.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

// Keys
const _themeKey = 'themeMode';
const _wifiSyncKey = 'wifiSyncEnabled';
const _lastEventKey = 'lastEventId';

/// Manages the user's preferred theme mode (light, dark, system)
final themeModeProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(_themeKey) ?? 'system';
});

/// Persist theme changes
final themeModePersisterProvider = Provider<void>((ref) {
  final mode = ref.watch(themeModeProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  prefs.setString(_themeKey, mode);
});

/// Manages whether photo syncing should only happen over Wi-Fi
final wifiSyncModeProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_wifiSyncKey) ?? false;
});

/// Persist wifi sync changes
final wifiSyncPersisterProvider = Provider<void>((ref) {
  final enabled = ref.watch(wifiSyncModeProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  prefs.setBool(_wifiSyncKey, enabled);
});

/// Stores the ID of the last event the user managed/joined
final lastEventIdProvider = StateProvider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(_lastEventKey);
});

/// Persist last event changes
final lastEventIdPersisterProvider = Provider<void>((ref) {
  final id = ref.watch(lastEventIdProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  if (id != null) {
    prefs.setString(_lastEventKey, id);
  } else {
    prefs.remove(_lastEventKey);
  }
});
