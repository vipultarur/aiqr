/// Design-token spacing, radius, and icon-size constants.
///
/// Replace every raw double (8, 12, 16, 24, 32 …) in widget files with these.
abstract final class AppDimensions {
  // ── Spacing ──────────────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ── Border radius ────────────────────────────────────────────────────────────
  static const double radiusXs = 6.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusPill = 40.0;
  static const double radiusFull = 100.0;

  // ── Icon sizes ───────────────────────────────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // ── Component sizes ──────────────────────────────────────────────────────────
  static const double buttonHeight = 56.0;
  static const double navItemSize = 48.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double logoDisplaySize = 96.0;

  // ── List ────────────────────────────────────────────────────────────────────
  /// Extra space at the bottom of scrollable lists to clear the floating nav bar.
  static const double listBottomPadding = 120.0;
}
