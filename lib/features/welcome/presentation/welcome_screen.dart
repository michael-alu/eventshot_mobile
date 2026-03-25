import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/constants/app_storage_keys.dart';
import '../../attendee/presentation/providers/attendee_providers.dart';
import '../../events/data/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isLoadingAttendee = false;

  Future<void> _joinAsAttendee() async {
    setState(() => _isLoadingAttendee = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastEventId = prefs.getString(AppStorageKeys.lastEventId);

      if (lastEventId != null && lastEventId.isNotEmpty) {
        final doc = await FirebaseFirestore.instance.collection('events').doc(lastEventId).get();
        if (doc.exists) {
          final data = doc.data()!;
          data['id'] = doc.id;
          final event = EventModel.fromJson(data).toEntity();

          ref.read(attendeeSessionProvider.notifier).setEvent(event.id, event.name);
          ref.read(attendeeSessionProvider.notifier).setPhotosTaken(event.photoCount);

          if (mounted) context.push(AppRouter.attendeeCamera);
          return;
        } else {
          await prefs.remove(AppStorageKeys.lastEventId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This event has been deleted by the organizer.')),
            );
          }
        }
      }
      if (mounted) context.push(AppRouter.attendeeManualCode);
    } catch(e) {
      if (mounted) context.push(AppRouter.attendeeManualCode);
    } finally {
      if (mounted) setState(() => _isLoadingAttendee = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/splash.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.65),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    'EventShot',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Memories made together',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The simplest way to collect and share photos from your event in real-time.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => context.push(AppRouter.organizerSignUp),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Sign Up as Organizer", style: TextStyle(fontSize: 16)),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push(AppRouter.attendeeSignUp),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text("Sign Up as Attendee", style: TextStyle(fontSize: 16)),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _isLoadingAttendee
                      ? const Center(child: CircularProgressIndicator())
                      : OutlinedButton.icon(
                          onPressed: _joinAsAttendee,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text("Join Event as Guest", style: TextStyle(fontSize: 16)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                        ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
