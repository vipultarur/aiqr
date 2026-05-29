// ── Ad Constants ──────────────────────────────────────────────────────────────
// PRESERVED: These exact strings are registered with AdMob.
// Never change them — mismatched IDs cause ad serving to fail silently.
// ─────────────────────────────────────────────────────────────────────────────

/// All Google Mobile Ads unit IDs, grouped by platform.
///
/// These are currently Google test IDs. Replace with production IDs before
/// publishing to the Play Store / App Store.
abstract final class AdConstants {
  // ── AdMob Application ID (also set in AndroidManifest.xml) ─────────────────
  // PRESERVED: ca-app-pub-3940256099942544~3347511713

  // ── Banner ──────────────────────────────────────────────────────────────────
  static const String bannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String bannerIos = 'ca-app-pub-3940256099942544/2934735716';

  // ── Interstitial ────────────────────────────────────────────────────────────
  static const String interstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String interstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  // ── App Open ────────────────────────────────────────────────────────────────
  static const String appOpenAndroid =
      'ca-app-pub-3940256099942544/9257395921';
  static const String appOpenIos = 'ca-app-pub-3940256099942544/5575463023';

  // ── Native ──────────────────────────────────────────────────────────────────
  static const String nativeAndroid =
      'ca-app-pub-3940256099942544/2247696110';
  static const String nativeIos = 'ca-app-pub-3940256099942544/3986624511';
}
