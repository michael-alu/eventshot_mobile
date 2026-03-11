import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

abstract class AppTheme {
  static TextTheme _textTheme(Color onSurface, Color onSurfaceVariant) {
    final base = GoogleFonts.plusJakartaSans();
    return TextTheme(
      displayLarge: base.copyWith(fontSize: 32, fontWeight: FontWeight.w700, color: onSurface),
      displayMedium: base.copyWith(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface),
      headlineLarge: base.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: onSurface),
      headlineMedium: base.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: base.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      titleLarge: base.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: base.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
      bodyLarge: base.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
      bodyMedium: base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: onSurface),
      bodySmall: base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariant),
      labelLarge: base.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
    );
  }

  static ThemeData get light {
    const onSurface = Color(0xFF0F172A);
    const onSurfaceVariant = AppColors.textMutedLight;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surfaceLight,
        error: Colors.red.shade700,
        onPrimary: Colors.white,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: _textTheme(onSurface, onSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const onSurface = Colors.white;
    const onSurfaceVariant = AppColors.textMutedDark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surfaceDark,
        error: Colors.red.shade400,
        onPrimary: Colors.white,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: _textTheme(onSurface, onSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
      ),
    );
  }
}
