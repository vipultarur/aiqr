import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aiqr_app/core/ads/ad_constants.dart';
import 'package:aiqr_app/core/utils/app_logger.dart';

/// Manages App-Open and Interstitial ad lifecycle.
///
/// All ad unit IDs are defined in [AdConstants] — never change them.
class AdService with WidgetsBindingObserver {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      showAppOpenAdIfAvailable();
    }
  }

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  
  /// Maximum duration allowed between loading and showing the ad (4 hours per AdMob docs).
  final Duration _maxCacheDuration = const Duration(hours: 4);
  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

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

  /// Loads an [AppOpenAd] ahead of time.
  void loadAppOpenAd({
    VoidCallback? onAdLoaded,
    VoidCallback? onAdFailedToLoad,
  }) {
    if (_appOpenAd != null) {
      onAdLoaded?.call();
      return; // Already loaded
    }

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
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
  void showAppOpenAdIfAvailable({VoidCallback? onAdDismissed}) {
    if (_appOpenAd == null) {
      AppLogger.warning('showAppOpenAd: ad not loaded yet');
      onAdDismissed?.call();
      loadAppOpenAd(); // Preload for next time
      return;
    }
    if (_isShowingAd) {
      AppLogger.warning('showAppOpenAd: another ad is already showing');
      onAdDismissed?.call();
      return;
    }

    if (_appOpenLoadTime != null && 
        DateTime.now().subtract(_maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      AppLogger.warning('AppOpenAd: Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      onAdDismissed?.call();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowingAd = true,
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.error('AppOpenAd failed to show', error);
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed?.call();
        loadAppOpenAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed?.call();
        loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
  }


  // ── Interstitial Ad ──────────────────────────────────────────────────────────

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  /// Loads an Interstitial Ad ahead of time.
  static void loadInterstitialAd() {
    _instance._loadInterstitialAdInternal();
  }

  void _loadInterstitialAdInternal() {
    if (_interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          AppLogger.warning('InterstitialAd failed to load: $error');
          _isInterstitialLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Shows the preloaded [InterstitialAd] and immediately preloads the next one.
  static void showInterstitialAd({required VoidCallback onAdDismissed}) {
    _instance._showInterstitialAdInternal(onAdDismissed: onAdDismissed);
  }

  void _showInterstitialAdInternal({required VoidCallback onAdDismissed}) {
    if (_interstitialAd == null) {
      AppLogger.warning('showInterstitialAd: Ad not ready, calling dismiss callback directly');
      onAdDismissed();
      _loadInterstitialAdInternal(); // Try loading again for next time
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed();
        _loadInterstitialAdInternal(); // PRELOAD NEXT AD
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.warning('showInterstitialAd failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed();
        _loadInterstitialAdInternal();
      },
    );

    _interstitialAd!.show();
  }
}
