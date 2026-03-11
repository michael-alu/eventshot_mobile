import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Modal showing QR code and 6-digit join code for event invite.
class QrInviteDialog extends StatelessWidget {
  const QrInviteDialog({
    super.key,
    required this.joinCode,
    this.qrWidget,
    this.onCopyLink,
    this.onSaveQr,
  });

  /// 6-character join code to display.
  final String joinCode;
  /// Custom QR widget (e.g. from qr_flutter); if null, a placeholder is shown.
  final Widget? qrWidget;
  final VoidCallback? onCopyLink;
  final VoidCallback? onSaveQr;

  static Future<void> show(
    BuildContext context, {
    required String joinCode,
    Widget? qrWidget,
    VoidCallback? onCopyLink,
    VoidCallback? onSaveQr,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => QrInviteDialog(
        joinCode: joinCode,
        qrWidget: qrWidget,
        onCopyLink: onCopyLink,
        onSaveQr: onSaveQr,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chars = joinCode.padRight(6).substring(0, 6).split('');

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius2xl * 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Text(
              'Invite Attendees',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan the QR code or enter the 6-digit code to start sharing photos.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius2xl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: qrWidget ??
                  SizedBox(
                    width: 192,
                    height: 192,
                    child: Center(
                      child: Icon(
                        Icons.qr_code_2,
                        size: 120,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'MANUAL JOIN CODE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < chars.length; i++) ...[
                  if (i == 3) const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primary,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Text(
                      chars[i].trim().isEmpty ? '' : chars[i],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (i < chars.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (onCopyLink != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCopyLink,
                      icon: const Icon(Icons.content_copy, size: 20),
                      label: const Text('Copy Link'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (onCopyLink != null && onSaveQr != null) const SizedBox(width: 12),
                if (onSaveQr != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSaveQr,
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('Save QR'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
