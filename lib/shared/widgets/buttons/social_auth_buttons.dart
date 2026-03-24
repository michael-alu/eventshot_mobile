import 'package:flutter/material.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    this.onGooglePressed,
    this.isGoogleLoading = false,
  });

  final VoidCallback? onGooglePressed;
  final bool isGoogleLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildIcon(IconData icon) {
      if (isGoogleLoading) {
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      }
      return Icon(icon, size: 20);
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR CONTINUE WITH',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isGoogleLoading ? null : (onGooglePressed ?? () {}),
            icon: buildIcon(Icons.mail_outline),
            label: const Text('Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
