import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/core/ads/ad_service.dart';
import 'package:aiqr_app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AdService _adService = AdService();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _loadAdAndNavigate();
  }

  void _loadAdAndNavigate() {
    // PERF: Reduced from 2s to 1s — users perceive the app as faster.
    // We also set a hard timeout so a slow ad network never blocks launch.
    final minDelay = Future.delayed(const Duration(milliseconds: 1000));
    final hardTimeout = Future.delayed(const Duration(seconds: 6));

    _adService.loadAppOpenAd(
      onAdLoaded: () => _proceedToMain(minDelay, showAd: true),
      onAdFailedToLoad: () => _proceedToMain(minDelay, showAd: false),
    );

    // Hard timeout: if nothing happened after 6s, force navigate.
    hardTimeout.then((_) => _navigateNow());
  }

  void _proceedToMain(Future<void> minDelay, {required bool showAd}) async {
    await minDelay;
    if (_hasNavigated) return;

    if (showAd) {
      _adService.showAppOpenAdIfAvailable(
        onAdDismissed: () => _navigateNow(),
      );
    } else {
      _navigateNow();
    }
  }

  void _navigateNow() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/logo/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_scanner, size: 100),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xFF4285F4), // Blue
                          Color(0xFFEA4335), // Red
                          Color(0xFFFBBC05), // Yellow
                          Color(0xFF34A853), // Green
                        ],
                      ).createShader(bounds);
                    },
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
