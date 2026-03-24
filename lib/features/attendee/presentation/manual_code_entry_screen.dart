import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../../shared/widgets/inputs/confirmation_code_field.dart';
import '../data/repositories/attendee_repository.dart';
import 'providers/attendee_providers.dart';

class ManualCodeEntryScreen extends ConsumerStatefulWidget {
  const ManualCodeEntryScreen({super.key});

  @override
  ConsumerState<ManualCodeEntryScreen> createState() =>
      _ManualCodeEntryScreenState();
}

class _ManualCodeEntryScreenState extends ConsumerState<ManualCodeEntryScreen> {
  String _code = '';
  bool _isLoading = false;

  Future<void> _onCompleted(String code) async {
    setState(() => _code = code);
    if (code.length == 6) {
      FocusScope.of(context).unfocus();
      setState(() => _isLoading = true);

      try {
        final repository = ref.read(attendeeRepositoryProvider);
        final event = await repository.validateJoinCode(code);
        
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        if (event != null) {
          ref.read(attendeeSessionProvider.notifier).setEvent(event.id, event.name);
          ref.read(attendeeSessionProvider.notifier).setPhotosTaken(event.photoCount);
          context.go(AppRouter.attendeeCamera);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid join code. Please try again.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to verify join code.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EsAppBar(title: 'Join Event'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                'Manual Code Entry',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-character code provided by the organizer to access the event gallery.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ConfirmationCodeField(
                onCompleted: _onCompleted,
                onChanged: (v) => setState(() => _code = v),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Join Event',
                onPressed: _code.length == 6 && !_isLoading
                    ? () => _onCompleted(_code)
                    : null,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              /*
              TextButton.icon(
                onPressed: () => context.go(AppRouter.attendeeScan),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code instead'),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}
