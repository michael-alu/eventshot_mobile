import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/providers.dart';
import '../core/services/offline_upload_manager.dart';
import '../core/theme/app_theme.dart';

class EventShotApp extends ConsumerWidget {
  const EventShotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly awaken the offline upload provider so it gracefully hums in the background
    ref.listen(offlineUploadManagerProvider, (previous, next) {});

    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'EventShot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
