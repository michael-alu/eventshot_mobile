import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import 'providers/auth_providers.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _timer;
  bool _canResend = true;
  int _cooldown = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerified() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.reloadUser();
    if (repo.isEmailVerified && mounted) {
      _timer?.cancel();
      context.go(AppRouter.organizerDashboard);
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    final repo = ref.read(authRepositoryProvider);
    await repo.sendEmailVerification();
    if (!mounted) return;
    setState(() {
      _canResend = false;
      _cooldown = 30;
    });
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _cooldown--);
      if (_cooldown <= 0) {
        t.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const EsAppBar(title: 'Verify Email'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Check your inbox',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to your email. '
                'Tap the link to verify your account.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: _canResend
                    ? 'Resend Email'
                    : 'Resend in $_cooldown s',
                onPressed: _canResend ? _resend : null,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final repo = ref.read(authRepositoryProvider);
                  final router = GoRouter.of(context);
                  await repo.signOut();
                  router.go(AppRouter.welcome);
                },
                child: const Text('Back to Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
