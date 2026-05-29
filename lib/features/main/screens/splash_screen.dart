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
  bool _adLoaded = false;
  bool _adFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAdAndNavigate();
  }

  void _loadAdAndNavigate() {
    // Add a minimum delay for the splash screen so it doesn't just flash
    final minDelay = Future.delayed(const Duration(seconds: 2));

    _adService.loadAppOpenAd(
      onAdLoaded: () {
        setState(() => _adLoaded = true);
        _proceedToMain(minDelay);
      },
      onAdFailedToLoad: () {
        setState(() => _adFailed = true);
        _proceedToMain(minDelay);
      },
    );
  }

  void _proceedToMain(Future<void> minDelay) async {
    await minDelay;
    if (_adLoaded) {
      _adService.showAppOpenAdIfAvailable(
        onAdDismissed: () {
          Get.offAllNamed(AppRoutes.main);
        },
      );
    } else {
      Get.offAllNamed(AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_scanner, size: 100),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
