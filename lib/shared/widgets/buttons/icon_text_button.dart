import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

/// Button with leading icon and label (e.g. "I'm Organizing an Event" with event icon).
class IconTextButton extends StatelessWidget {
  const IconTextButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.fullWidth = true,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconTheme(data: IconThemeData(size: 22, color: primary ? Colors.white : theme.colorScheme.onSurface), child: icon),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primary ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );

    if (primary) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: 56,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
        ),
        child: child,
      ),
    );
  }
}
