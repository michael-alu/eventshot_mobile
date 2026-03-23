import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import 'providers/attendee_providers.dart';

class AttendeeCameraScreen extends ConsumerWidget {
  const AttendeeCameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(attendeeSessionProvider);
    final notifier = ref.read(attendeeSessionProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated camera preview (full screen)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1a1a1a),
              child: const Center(
                child: Icon(Icons.camera_alt, size: 80, color: Colors.white12),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, session),
                const Spacer(),
                _buildBottomControls(context, session, notifier),
              ],
            ),
          ),

          // Bottom nav bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AttendeeSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRouter.welcome);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPhotosRemainingCard(session),
        ],
      ),
    );
  }

  Widget _buildPhotosRemainingCard(AttendeeSession session) {
    final progress = session.photosTaken / session.photoLimit;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_library,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Photos Remaining',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${session.photosRemaining}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: '/${session.photoLimit}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    AttendeeSession session,
    AttendeeSessionNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80, left: 40, right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flash toggle
          GestureDetector(
            onTap: () => notifier.setFlash(!session.flashOn),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(
                session.flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),

          // Shutter button
          GestureDetector(
            onTap: () {
              notifier.incrementPhotoCount();
              context.push(AppRouter.photoReview);
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Gallery preview thumbnail
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.white24,
              ),
              child: ClipOval(
                child: session.lastPhotoPath != null
                    ? Image.asset(session.lastPhotoPath!, fit: BoxFit.cover)
                    : const Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRouter.welcome);
              }
            },
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.white54,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.camera_alt,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white54,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
