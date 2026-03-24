import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:camera/camera.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/dialogs/leave_event_dialog.dart';
import 'providers/attendee_providers.dart';

class AttendeeCameraScreen extends ConsumerStatefulWidget {
  const AttendeeCameraScreen({super.key});

  @override
  ConsumerState<AttendeeCameraScreen> createState() => _AttendeeCameraScreenState();
}

class _AttendeeCameraScreenState extends ConsumerState<AttendeeCameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() => _isCameraInitialized = true);
      final session = ref.read(attendeeSessionProvider);
      await _controller!.setFlashMode(
        session.flashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _showLeaveEventDialog(BuildContext context) async {
    await LeaveEventDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(attendeeSessionProvider);
    final notifier = ref.read(attendeeSessionProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1a1a1a),
              child: _isCameraInitialized && _controller != null
                  ? CameraPreview(_controller!)
                  : const Center(
                      child: CircularProgressIndicator(),
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
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showLeaveEventDialog(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.white, size: 20),
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
          GestureDetector(
            onTap: () async {
              if (_controller == null) return;
              final newFlashState = !session.flashOn;
              notifier.setFlash(newFlashState);
              await _controller!.setFlashMode(
                newFlashState ? FlashMode.torch : FlashMode.off,
              );
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
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
          GestureDetector(
            onTap: () async {
              if (_controller == null || !_controller!.value.isInitialized) return;
              if (_controller!.value.isTakingPicture) return;

              try {
                final file = await _controller!.takePicture();
                notifier.setLastPhotoPath(file.path);
                if (context.mounted) {
                  context.push(AppRouter.photoReview);
                }
              } catch (e) {
                debugPrint('Take picture error: $e');
              }
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
                child: InkWell(
                  onTap: () {
                    if (session.eventId != null) {
                      context.push('${AppRouter.gallery}/${session.eventId}');
                    }
                  },
                  child: session.lastPhotoPath != null
                      ? Image.file(File(session.lastPhotoPath!), fit: BoxFit.cover)
                      : const Icon(Icons.person, color: Colors.white, size: 28),
                ),
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
