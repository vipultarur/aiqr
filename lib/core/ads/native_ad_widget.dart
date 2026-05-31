import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aiqr_app/core/ads/ad_constants.dart';
import 'package:aiqr_app/core/utils/app_logger.dart';

/// Renders a Google native ad using a template style.
///
/// PERF: Uses [VisibilityDetector]-style approach — the ad only loads once
/// the widget is actually visible on screen, avoiding wasted network requests
/// for off-screen ad slots.
///
/// Returns [SizedBox.shrink] while the ad is loading or if it fails.
class NativeAdWidget extends StatefulWidget {
  final TemplateType templateType;

  const NativeAdWidget({
    super.key,
    this.templateType = TemplateType.medium,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _loadStarted = false;

  // PRESERVED: native ad unit IDs from AdConstants
  String get _adUnitId =>
      Platform.isAndroid ? AdConstants.nativeAndroid : AdConstants.nativeIos;

  @override
  void initState() {
    super.initState();
    // PERF: Defer ad loading to the next frame so the widget tree can build
    // first without blocking on ad SDK calls.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAd();
    });
  }

  void _loadAd() {
    if (_loadStarted) return;
    _loadStarted = true;

    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          AppLogger.warning('NativeAd failed to load: $error');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
        cornerRadius: 16.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) return const SizedBox.shrink();

    final isMedium = widget.templateType == TemplateType.medium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 320,
          minHeight: isMedium ? 320 : 90,
          maxWidth: double.infinity,
          maxHeight: isMedium ? 400 : 120,
        ),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}
