import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/section_header.dart';
import '../../../shared/widgets/cards/stat_card.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../../shared/widgets/dialogs/qr_invite_dialog.dart';
import '../../events/domain/entities/event.dart';
import '../../events/presentation/providers/event_providers.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(watchEventProvider(eventId));

    return Scaffold(
      appBar: EsAppBar(
        title: eventAsync.valueOrNull?.name ?? 'Event Details',
      ),
      body: eventAsync.when(
        data: (event) => _buildContent(context, ref, event),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Event? event) {
    if (event == null) return const Center(child: Text('Event not found.'));

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
                  const Icon(Icons.workspace_premium, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro Plan', // Example display
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
                onSaveQr: () => Navigator.of(context).pop(), // simplified action
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
