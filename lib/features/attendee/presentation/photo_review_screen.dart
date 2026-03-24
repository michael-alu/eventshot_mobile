import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/offline_upload_manager.dart';
import '../data/repositories/attendee_repository.dart';
import 'providers/attendee_providers.dart';

class PhotoReviewScreen extends ConsumerStatefulWidget {
  const PhotoReviewScreen({super.key});

  @override
  ConsumerState<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends ConsumerState<PhotoReviewScreen> {
  bool _isUploading = false;

  Future<void> _uploadPhoto() async {
    final session = ref.read(attendeeSessionProvider);
    if (session.lastPhotoPath == null || session.eventId == null) return;

    setState(() => _isUploading = true);

    try {
      final repository = ref.read(attendeeRepositoryProvider);
      await repository.assertUploadLimit(session.eventId!);
      await ref.read(offlineUploadManagerProvider.notifier).enqueue(session.eventId!, File(session.lastPhotoPath!));

      if (!mounted) return;
      ref.read(attendeeSessionProvider.notifier).incrementPhotoCount();
      ref.read(attendeeSessionProvider.notifier).setLastPhotoPath(null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo added to upload queue!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      debugPrint('UPLOAD ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload photo. Please try again.')),
      );
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1a1a1a),
              child: Consumer(
                builder: (context, ref, child) {
                  final path = ref.watch(attendeeSessionProvider).lastPhotoPath;
                  if (path != null) {
                    return Image.file(
                      File(path),
                      fit: BoxFit.cover,
                    );
                  }
                  return const Center(
                    child: Icon(Icons.broken_image, size: 80, color: Colors.white12),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.zoom_in, color: Colors.white, size: 22),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ready to share?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isUploading ? null : _uploadPhoto,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(
              _isUploading ? 'Uploading...' : 'Save to Event',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isUploading
                ? null
                : () {
                    ref.read(attendeeSessionProvider.notifier).setLastPhotoPath(null);
                    context.pop();
                  },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Discard',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.verified, color: AppColors.primary, size: 16),
              SizedBox(width: 6),
              Text(
                'Premium Uploading Enabled',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
