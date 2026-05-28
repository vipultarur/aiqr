import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// App Color System
/// Brand Theme: QR Marker
/// Primary: #895AF6
/// Light Background: #F3EFFE
/// ---------------------------------------------------------------------------
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────
  // BRAND COLORS
  // ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF895AF6);
  static const Color primaryDark = Color(0xFF6B3FD4);
  static const Color primaryLight = Color(0xFFA17DF8);

  static const Color secondary = Color(0x1A895AF6);

  // Seed Color
  static const Color seed = primary;

  // ─────────────────────────────────────────────────────────────
  // BACKGROUND & SURFACE
  // ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF3EFFE);
  static const Color surface = Colors.white;

  static const Color container = Color(0xFFDCD0F8);
  static const Color surfaceVariant = Color(0xFFF6F5F8);

  // Dark Theme
  static const Color darkBackground = Color(0xFF110D1B);
  static const Color darkSurface = Color(0xFF1C1526);
  static const Color darkSurfaceVariant = Color(0xFF2A2136);

  // ─────────────────────────────────────────────────────────────
  // TEXT COLORS
  // ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1C1526);
  static const Color textSecondary = Color(0xFF9992AB);
  static const Color textHint = Color(0xFFB8B3C6);

  static const Color textWhite = Colors.white;

  // ─────────────────────────────────────────────────────────────
  // STATUS COLORS
  // ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2979FF);

  // ─────────────────────────────────────────────────────────────
  // QR COLORS
  // ─────────────────────────────────────────────────────────────
  static const Color qrPattern = Colors.black;
  static const Color qrBackground = Colors.white;

  static const Color qrFinderOuter = Colors.black;
  static const Color qrFinderInner = Colors.black;

  static const Color qrFrameText = primary;

  // ─────────────────────────────────────────────────────────────
  // TAB COLORS
  // ─────────────────────────────────────────────────────────────
  static const Color tabBackground = Color(0xFFF9F7FF);
  static const Color tabFrame = Color(0xFFF9F7FF);

  // ─────────────────────────────────────────────────────────────
  // GRADIENTS
  // ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF895AF6),
      Color(0xFFA17DF8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [
      Color(0xFF895AF6),
      Color(0xFFA17DF8),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Dynamic Screen Background Gradient
  static LinearGradient backgroundGradient(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const LinearGradient(
        colors: [
          Color(0xFFF3EFFE),
          Colors.white,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    return const LinearGradient(
      colors: [
        Color(0xFF1C1526),
        Color(0xFF110D1B),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
