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
  static String get bannerAndroid => kDebugMode 
      ? 'ca-app-pub-3940256099942544/6300978111' 
      : 'ca-app-pub-9155918242947466/8881998382';
  static String get bannerIos => kDebugMode 
      ? 'ca-app-pub-3940256099942544/2934735716' 
      : 'ca-app-pub-9155918242947466/8881998382';

  // ── Interstitial ────────────────────────────────────────────────────────────
  static String get interstitialAndroid => kDebugMode 
      ? 'ca-app-pub-3940256099942544/1033173712' 
      : 'ca-app-pub-9155918242947466/2941452165';
  static String get interstitialIos => kDebugMode 
      ? 'ca-app-pub-3940256099942544/4411468910' 
      : 'ca-app-pub-9155918242947466/2941452165';

  // ── App Open ────────────────────────────────────────────────────────────────
  static String get appOpenAndroid => kDebugMode 
      ? 'ca-app-pub-3940256099942544/9257395921' 
      : 'ca-app-pub-9155918242947466/2388742221';
  static String get appOpenIos => kDebugMode 
      ? 'ca-app-pub-3940256099942544/5575463023' 
      : 'ca-app-pub-9155918242947466/2388742221';

  // ── Native ──────────────────────────────────────────────────────────────────
  static String get nativeAndroid => kDebugMode 
      ? 'ca-app-pub-3940256099942544/2247696110' 
      : 'ca-app-pub-9155918242947466/2444582544';
  static String get nativeIos => kDebugMode 
      ? 'ca-app-pub-3940256099942544/3986624511' 
      : 'ca-app-pub-9155918242947466/2444582544';
}
