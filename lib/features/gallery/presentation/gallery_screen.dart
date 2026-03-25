import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../../shared/widgets/dialogs/leave_event_dialog.dart';
import '../../../shared/widgets/dialogs/qr_invite_dialog.dart';
import '../../events/presentation/providers/event_providers.dart';
import '../data/providers/gallery_providers.dart';

enum _PhotoFilter { all, mine, others }

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key, required this.eventId, this.eventTitle, this.showTakePictures = false});

  final String eventId;
  final String? eventTitle;
  final bool showTakePictures;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  bool _isDownloading = false;
  _PhotoFilter _filter = _PhotoFilter.all;

  @override
  Widget build(BuildContext context) {
    final defaultTitle = widget.eventTitle ?? widget.eventId;
    final eventAsync = ref.watch(watchEventProvider(widget.eventId));
    final title = eventAsync.valueOrNull?.joinCode ?? defaultTitle;

    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;
    final isLoggedIn = currentUser != null && !(currentUser.isAnonymous);
    final canTakePictures = isLoggedIn && widget.showTakePictures;

    return Scaffold(
      appBar: EsAppBar(
        title: title,
        actions: [
          IconButton(
            onPressed: () => QrInviteDialog.show(context, joinCode: title),
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'Share Event Code',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildChip('All Photos', _PhotoFilter.all),
                const SizedBox(width: 8),
                _buildChip('My Photos', _PhotoFilter.mine),
                const SizedBox(width: 8),
                _buildChip("Others' Photos", _PhotoFilter.others),
              ],
            ),
          ),

          Expanded(
            child: ref.watch(galleryPhotoDocsProvider(widget.eventId)).when(
              data: (allPhotos) {
                // Apply the selected filter chip logic to the raw photo list
                final photos = _applyFilter(allPhotos, uid);
                
                if (photos.isEmpty) {
                  final message = _filter == _PhotoFilter.all
                      ? 'No photos yet! Grab your camera!'
                      : _filter == _PhotoFilter.mine
                          ? 'You haven\'t taken any photos yet.'
                          : 'No photos from others yet.';
                  return Center(
                    child: Text(
                      message,
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
                    final url = photos[index]['url'] as String;
                    return InkWell(
                      onTap: () {
                        context.push('/photo?url=${Uri.encodeComponent(url)}');
                      },
                      child: Hero(
                        tag: url,
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                        ),
                      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canTakePictures) ...[
                FilledButton.tonalIcon(
                  onPressed: () => context.push(AppRouter.attendeeCamera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take More Pictures'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton.icon(
                onPressed: _isDownloading
                    ? null
                    : () async {
                        final isAnon = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
                        if (isAnon) {
                          LeaveEventDialog.show(context);
                          return;
                        }
                        
                        setState(() => _isDownloading = true);
                        try {
                          final String url = CloudinaryService.generateArchiveUrl(eventId: widget.eventId);
                          await launchUrlString(url, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          if (context.mounted) SnackbarHelper.showError(context, e.toString());
                        } finally {
                          if (mounted) setState(() => _isDownloading = false);
                        }
                      },
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download),
                label: Text(_isDownloading ? 'Archiving...' : 'Download All'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, _PhotoFilter filter) {
    final isSelected = _filter == filter;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = filter),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> photos, String? uid) {
    // If "All Photos" is selected or user is not logged in, return everything
    if (_filter == _PhotoFilter.all || uid == null) return photos;
    
    // Filter to only show photos uploaded by the current user
    if (_filter == _PhotoFilter.mine) {
      return photos.where((p) => p['uploadedBy'] == uid).toList();
    }
    
    // Filter to only show photos uploaded by everyone else
    return photos.where((p) => p['uploadedBy'] != uid).toList();
  }
}

