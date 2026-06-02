import 'dart:io';
import 'dart:async';

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
  
  Timer? _reloadTimer;
  int _retryCount = 0;
  static const int _maxRetries = 100;

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

  void _scheduleReload() {
    _reloadTimer?.cancel();
    _reloadTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _loadAd();
      }
    });
  }

  void _loadAd() {
    _nativeAd?.dispose();
    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _retryCount = 0; // Reset on success
            });
            _scheduleReload();
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          AppLogger.warning('NativeAd failed to load: $error');
          if (mounted && _retryCount < _maxRetries) {
            _retryCount++;
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) _loadAd();
            });
          }
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
    _reloadTimer?.cancel();
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
        child: Stack(
          children: [
            AdWidget(ad: _nativeAd!),
            const Positioned(
              top: 0,
              left: 0,
              child: _AnimatedAdBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedAdBadge extends StatefulWidget {
  const _AnimatedAdBadge();

  @override
  State<_AnimatedAdBadge> createState() => _AnimatedAdBadgeState();
}

class _AnimatedAdBadgeState extends State<_AnimatedAdBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), // Match native ad corner radius
            bottomRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.4),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars_rounded, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'AD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
