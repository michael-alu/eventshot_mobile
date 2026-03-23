import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_shadows.dart';

/// Primary CTA button: rounded-xl, primary color, shadow, optional full width.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool fullWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : (icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 12),
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              )
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)));

    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: onPressed == null ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppShadows.primaryButton,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
