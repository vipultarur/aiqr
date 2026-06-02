// ── Ad Constants ──────────────────────────────────────────────────────────────
// PRESERVED: These exact strings are registered with AdMob.
// Never change them — mismatched IDs cause ad serving to fail silently.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

/// All Google Mobile Ads unit IDs, grouped by platform.
abstract final class AdConstants {
  // ── AdMob Application ID (also set in AndroidManifest.xml) ─────────────────
  // PRESERVED: ca-app-pub-9155918242947466~1470942459

  // ── Banner ──────────────────────────────────────────────────────────────────
  static String get bannerAndroid => 'ca-app-pub-9155918242947466/8881998382';
  static String get bannerIos => 'ca-app-pub-9155918242947466/8881998382';

  // ── Interstitial ────────────────────────────────────────────────────────────
  static String get interstitialAndroid => 'ca-app-pub-9155918242947466/2941452165';
  static String get interstitialIos => 'ca-app-pub-9155918242947466/2941452165';

  // ── App Open ────────────────────────────────────────────────────────────────
  static String get appOpenAndroid => 'ca-app-pub-9155918242947466/2388742221';
  static String get appOpenIos => 'ca-app-pub-9155918242947466/2388742221';

  // ── Native ──────────────────────────────────────────────────────────────────
  static String get nativeAndroid => 'ca-app-pub-9155918242947466/2444582544';
  static String get nativeIos => 'ca-app-pub-9155918242947466/2444582544';
}
