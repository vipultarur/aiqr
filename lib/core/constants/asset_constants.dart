// ── Asset Constants ────────────────────────────────────────────────────────────
// PRESERVED: Asset paths must match pubspec.yaml flutter.assets declarations.
// ─────────────────────────────────────────────────────────────────────────────

/// Compile-time asset path constants.
/// Zero raw strings in widget code — always reference these.
abstract final class AssetConstants {
  // ── Images ───────────────────────────────────────────────────────────────────
  static const String logoImage = 'assets/logo/logo.png';
  static const String brandingFore = 'assets/branding/aiqr_fore.png';

  // ── Sounds ───────────────────────────────────────────────────────────────────
  // PRESERVED: referenced by FlutterRingtonePlayer — path cannot change
  static const String scanPingSound = 'assets/sounds/scan_ping.mp3';
}
