import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/section_header.dart';
import '../../../shared/widgets/cards/stat_card.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../../shared/widgets/dialogs/qr_invite_dialog.dart';
import '../../events/domain/entities/event.dart';
import '../../events/presentation/providers/event_providers.dart';
import '../../gallery/data/providers/gallery_providers.dart';

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

    // Live Cloudinary storage stat
    final statsAsync = ref.watch(cloudinaryStatsProvider(eventId));
    final storageLabel = statsAsync.when(
      data: (stats) => '${stats.totalMb.toStringAsFixed(1)} MB',
      loading: () => '...',
      error: (err, stack) => 'N/A',
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
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
            child: StatCard(label: 'Storage Used', value: storageLabel),
          ),
          const SizedBox(height: 8),
          const SectionHeader(title: 'Event Photos'),
          _EventPhotoGrid(eventId: eventId),
          const SizedBox(height: 24),
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

class _EventPhotoGrid extends ConsumerWidget {
  const _EventPhotoGrid({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(galleryPhotosProvider(eventId));

    return photosAsync.when(
      data: (photos) {
        if (photos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No photos yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                photos[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Could not load photos: $e'),
      ),
    );
  }
}
