import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  
  // Test Ad Unit IDs
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9257395921'; // Google test ID for App Open Ad
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5575463023';
    }
    throw UnsupportedError('Unsupported platform');
  }

  // --- App Open Ad Logic ---

  /// Load an AppOpenAd.
  void loadAppOpenAd({VoidCallback? onAdLoaded, VoidCallback? onAdFailedToLoad}) {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          if (onAdLoaded != null) onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          if (onAdFailedToLoad != null) onAdFailedToLoad();
        },
      ),
    );
  }

  /// Shows the app open ad, and executes a callback when the ad is closed.
  void showAppOpenAdIfAvailable({required VoidCallback onAdDismissed}) {
    if (_appOpenAd == null) {
      debugPrint('Warning: attempt to show app open ad before loaded.');
      onAdDismissed();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Warning: attempt to show app open ad while another ad is showing.');
      onAdDismissed();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AppOpenAd failed to show: $error');
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

  // --- Interstitial Ad Logic ---

  /// Load and show an InterstitialAd, executing the callback when dismissed.
  static void showInterstitialAd({required VoidCallback onAdDismissed}) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              onAdDismissed();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              onAdDismissed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          onAdDismissed();
        },
      ),
    );
  }
}
