import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: Colors.black,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          fontFamily: 'DMSans',
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'GSansFlex'),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textPrimary),
        bodySmall: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textSecondary),
        labelLarge: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primary,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.darkSurfaceVariant,
        surface: AppColors.darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          fontFamily: 'DMSans',
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'GSansFlex'),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'DMSans', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontFamily: 'DMSans', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontFamily: 'DMSans', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontFamily: 'DMSans', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: 'DMSans', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontFamily: 'DMSans', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: 'DMSans', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontFamily: 'DMSans', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(fontFamily: 'DMSans', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textWhite),
        bodyMedium: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textWhite),
        bodySmall: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textHint),
        labelLarge: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textWhite, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textWhite, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontFamily: 'GSansFlex', color: AppColors.textHint, fontWeight: FontWeight.w500),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primary,
      ),
      useMaterial3: true,
    );
  }

  static const Map<String, Color> formatColors = {
    'URL': AppColors.primaryLight,
    'Wi-Fi': AppColors.success,
    'Text': AppColors.warning,
    'vCard': AppColors.error,
    'Email': AppColors.primaryLight,
    'UPI': AppColors.info,
  };
}
