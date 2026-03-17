import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/section_header.dart';
import '../../../shared/widgets/cards/stat_card.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../../shared/widgets/dialogs/qr_invite_dialog.dart';
import '../../events/domain/entities/event.dart';
import '../../events/presentation/providers/event_providers.dart';

class OrganizerDashboardScreen extends ConsumerWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = ref.watch(currentEventIdProvider);
    final eventAsync = eventId != null
        ? ref.watch(watchEventProvider(eventId))
        : const AsyncValue<Event?>.data(null);

    return Scaffold(
      appBar: EsAppBar(
        title: eventAsync.valueOrNull?.name ?? 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: eventId == null
          ? _buildEmptyState(context)
          : eventAsync.when(
              data: (event) => _buildContent(context, ref, event),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No event selected',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create an event to see your dashboard and share access with attendees.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create Event',
              onPressed: () => context.push(AppRouter.createEvent),
              icon: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Event? event) {
    if (event == null) return _buildEmptyState(context);

    final photoCount = event.photoCount.toString();
    final attendeeCount = event.attendeeCount.toString();
    final storageGb = (event.storageBytes / (1024 * 1024 * 1024)).toStringAsFixed(1);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro Plan',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Unlimited High-Res Uploads',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Event Stats'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: StatCard(label: 'Photos', value: photoCount)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(label: 'Attendees', value: attendeeCount)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StatCard(label: 'Storage', value: '$storageGb GB'),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PrimaryButton(
              label: 'Share Event Access',
              icon: const Icon(Icons.qr_code_2, color: Colors.white, size: 22),
              onPressed: () => QrInviteDialog.show(
                context,
                joinCode: event.joinCode.isEmpty ? 'LOADING' : event.joinCode,
                onSaveQr: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
