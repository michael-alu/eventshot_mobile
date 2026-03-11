import 'package:flutter/material.dart';

import 'app_colors.dart';

/// EventShot design system shadows and z-index.
abstract class AppShadows {
  static const int zAppBar = 10;
  static const int zBottomNav = 20;
  static const int zModal = 50;
  static const int zOverlay = 100;

  /// Primary button / CTA shadow (shadow-primary/20).
  static List<BoxShadow> get primaryButton => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Card / surface shadow (light).
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Modal / dialog shadow.
  static List<BoxShadow> get modal => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
