import 'package:flutter/animation.dart';

/// App-wide design and timing constants.
///
/// Every magic number lives here. Widget files must not contain raw doubles
/// for spacing, radii, durations, or sizes.
abstract final class AppConstants {
  // ── Animations ───────────────────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 200);
  static const Duration animSlow = Duration(milliseconds: 300);
  static const Curve animCurve = Curves.easeInOut;

  // ── Splash ───────────────────────────────────────────────────────────────────
  static const Duration splashMinDelay = Duration(seconds: 2);

  // ── Gallery scan ─────────────────────────────────────────────────────────────
  static const Duration galleryScanDelay = Duration(milliseconds: 1500);

  // ── History ──────────────────────────────────────────────────────────────────
  /// Number of recent history items shown on the home tab.
  static const int homeHistoryPreviewCount = 3;

  // ── QR image export ──────────────────────────────────────────────────────────
  /// Logical size of the QR preview widget inside RepaintBoundary.
  /// Used to calculate pixelRatio for export.
  static const double qrPreviewLogicalSize = 232.0;

  // ── Touch targets ────────────────────────────────────────────────────────────
  static const double minTouchTarget = 48.0;
}
