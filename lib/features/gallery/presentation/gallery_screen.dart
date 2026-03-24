import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/widgets/chips/filter_chip_row.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../../shared/widgets/dialogs/leave_event_dialog.dart';
import '../../../shared/widgets/dialogs/qr_invite_dialog.dart';
import '../../events/presentation/providers/event_providers.dart';
import '../data/providers/gallery_providers.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key, required this.eventId, this.eventTitle});

  final String eventId;
  final String? eventTitle;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final defaultTitle = widget.eventTitle ?? widget.eventId;
    final eventAsync = ref.watch(watchEventProvider(widget.eventId));
    final title = eventAsync.valueOrNull?.joinCode ?? defaultTitle;

    return Scaffold(
      appBar: EsAppBar(
        title: title,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Export',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          FilterChipRow(
            labels: const ['All Photos', 'Latest', 'Most Popular', 'My Photos'],
            selectedIndex: _filterIndex,
            onSelected: (i) => setState(() => _filterIndex = i),
          ),
          Expanded(
            child: ref.watch(galleryPhotosProvider(widget.eventId)).when(
              data: (photos) {
                if (photos.isEmpty) {
                  return Center(
                    child: Text(
                      'No photos yet! Grab your camera!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      photos[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () =>
                    QrInviteDialog.show(context, joinCode: widget.eventId),
                child: const Icon(Icons.qr_code_2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final isAnon = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
                    if (isAnon) {
                      LeaveEventDialog.show(context);
                    } else {
                      // TODO: Implement actual multiple download functionality
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download All'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
