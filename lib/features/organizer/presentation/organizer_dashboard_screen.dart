import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/cards/section_header.dart';
import '../../../shared/widgets/cards/stat_card.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../events/presentation/providers/event_providers.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class OrganizerDashboardScreen extends ConsumerWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(aggregateStatsProvider);
    final eventsAsync = ref.watch(organizerEventsProvider);

    return Scaffold(
      appBar: EsAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go(AppRouter.organizerProfile),
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (events) {
          if (events.isEmpty) return _buildEmptyState(context);
          return _buildContent(context, stats);
        },
      ),
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
              'Welcome to EventShot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create an event to see your overall dashboard and share access with attendees.',
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

  Widget _buildContent(BuildContext context, AggregateStats stats) {
    final storageGb = (stats.totalStorageBytes / (1024 * 1024 * 1024)).toStringAsFixed(2);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Overview'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: StatCard(label: 'Total Events', value: '${stats.totalEvents}')),
                const SizedBox(width: 16),
                Expanded(child: StatCard(label: 'Total Photos', value: '${stats.totalPhotos}')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: StatCard(label: 'Total Attendees', value: '${stats.totalAttendees}')),
                const SizedBox(width: 16),
                Expanded(child: StatCard(label: 'Used Storage', value: '$storageGb GB')),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
