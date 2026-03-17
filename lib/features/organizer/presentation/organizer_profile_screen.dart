import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/preferences_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../auth/presentation/providers/auth_providers.dart';

class OrganizerProfileScreen extends ConsumerWidget {
  const OrganizerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final wifiSync = ref.watch(wifiSyncModeProvider);

    final name = user?.displayName ?? 'Organizer';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'O';

    return Scaffold(
      appBar: const EsAppBar(
        title: 'Profile & Settings',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary,
                child: Text(
                  initials,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            
            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'PREFERENCES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.dark_mode, size: 20, color: theme.colorScheme.onPrimaryContainer),
                    ),
                    title: const Text('Theme Mode'),
                    trailing: DropdownButton<String>(
                      value: themeMode,
                      borderRadius: BorderRadius.circular(12),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'system', child: Text('System')),
                        DropdownMenuItem(value: 'light', child: Text('Light')),
                        DropdownMenuItem(value: 'dark', child: Text('Dark')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(themeModeProvider.notifier).state = value;
                          // Trigger persistence
                          ref.read(themeModePersisterProvider);
                        }
                      },
                    ),
                  ),
                  Divider(height: 1, indent: 56, endIndent: 16, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.wifi, size: 20, color: theme.colorScheme.onTertiaryContainer),
                    ),
                    title: const Text('Wi-Fi Sync Only'),
                    subtitle: const Text('Upload photos only when connected to Wi-Fi'),
                    value: wifiSync,
                    onChanged: (value) {
                      ref.read(wifiSyncModeProvider.notifier).state = value;
                      // Trigger persistence
                      ref.read(wifiSyncPersisterProvider);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'ACCOUNT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.logout, size: 20, color: theme.colorScheme.error),
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) {
                    context.go(AppRouter.welcome);
                  }
                },
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
