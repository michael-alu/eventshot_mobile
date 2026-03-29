import 'package:eventshot_mobile/core/constants/app_colors.dart';
import 'package:eventshot_mobile/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants Unit Tests', () {
    test('AppColors are correct', () {
      expect(AppColors.primary, const Color(0xFF137FEC));
      expect(AppColors.backgroundLight, const Color(0xFFF6F7F8));
      expect(AppColors.backgroundDark, const Color(0xFF101922));
      expect(AppColors.surfaceLight, const Color(0xFFFFFFFF));
      expect(AppColors.surfaceDark, const Color(0xFF1C2127));
    });

    test('AppSizes constants exist', () {
      expect(AppSizes.radiusSm, 4.0);
      expect(AppSizes.radiusLg, 8.0);
      expect(AppSizes.radiusXl, 12.0);
      expect(AppSizes.radius2xl, 16.0);
      expect(AppSizes.radiusFull, 9999.0);

      expect(AppSizes.spacingXs, 4.0);
      expect(AppSizes.spacingSm, 8.0);
      expect(AppSizes.spacingMd, 16.0);
      expect(AppSizes.spacingLg, 24.0);
      expect(AppSizes.spacingXl, 32.0);
    });
  });
}
