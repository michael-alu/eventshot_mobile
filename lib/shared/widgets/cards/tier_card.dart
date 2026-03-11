import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Pricing tier card (Starter / Pro / Unlimited).
class TierCard extends StatelessWidget {
  const TierCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    this.priceSuffix = 'One-time',
    this.features = const [],
    this.isSelected = false,
    this.badge,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final String priceSuffix;
  final List<String> features;
  final bool isSelected;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected ? AppColors.primary : theme.colorScheme.outline.withValues(alpha: 0.5);
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.08)
        : theme.colorScheme.surface;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (badge != null)
          Positioned(
            top: -12,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                badge!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.primary : null,
                            ),
                          ),
                          Text(
                            priceSuffix.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.8)
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (features.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                f,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (isSelected)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
