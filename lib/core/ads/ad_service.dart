import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aiqr_app/core/ads/ad_constants.dart';
import 'package:aiqr_app/core/utils/app_logger.dart';

/// Manages App-Open and Interstitial ad lifecycle.
///
/// All ad unit IDs are defined in [AdConstants] — never change them.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  // ── Unit ID helpers ──────────────────────────────────────────────────────────

  // PRESERVED: all ad unit strings live in AdConstants
  static String get bannerAdUnitId =>
      Platform.isAndroid ? AdConstants.bannerAndroid : AdConstants.bannerIos;

  static String get interstitialAdUnitId => Platform.isAndroid
      ? AdConstants.interstitialAndroid
      : AdConstants.interstitialIos;

  static String get appOpenAdUnitId => Platform.isAndroid
      ? AdConstants.appOpenAndroid
      : AdConstants.appOpenIos;

  // ── App Open Ad ──────────────────────────────────────────────────────────────

  /// Loads an [AppOpenAd] and calls [onAdLoaded] or [onAdFailedToLoad].
  void loadAppOpenAd({
    VoidCallback? onAdLoaded,
    VoidCallback? onAdFailedToLoad,
  }) {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          AppLogger.warning('AppOpenAd failed to load: $error');
          onAdFailedToLoad?.call();
        },
      ),
    );
  }

  /// Shows the loaded [AppOpenAd] if available and not already showing.
  void showAppOpenAdIfAvailable({required VoidCallback onAdDismissed}) {
    if (_appOpenAd == null) {
      AppLogger.warning('showAppOpenAd: ad not loaded yet');
      onAdDismissed();
      return;
    }
    if (_isShowingAd) {
      AppLogger.warning('showAppOpenAd: another ad is already showing');
      onAdDismissed();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowingAd = true,
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.error('AppOpenAd failed to show', error);
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed();
      },
    );
    _appOpenAd!.show();
  }

  // ── Interstitial Ad ──────────────────────────────────────────────────────────

  /// Loads and immediately shows an [InterstitialAd], then calls
  /// [onAdDismissed] whether the ad showed or failed.
  static void showInterstitialAd({required VoidCallback onAdDismissed}) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdDismissed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onAdDismissed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          AppLogger.warning('InterstitialAd failed to load: $error');
          onAdDismissed();
        },
      ),
    );
  }
}
