import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/features/generator/controllers/qr_maker_controller.dart';
import 'package:aiqr_app/routes/app_routes.dart';
import 'package:aiqr_app/core/theme/app_theme.dart';
import 'package:aiqr_app/features/history/controllers/history_controller.dart';
import 'package:aiqr_app/features/settings/services/settings_service.dart';
import 'package:aiqr_app/features/settings/controllers/settings_controller.dart';
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aiqr_app/core/ads/ad_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:aiqr_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ── Firebase Initialisation ──────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Core initialisation ──────────────────────────────────────────────────────
  // PERF: Initialize settings synchronously — it's fast (SharedPreferences).
  final settingsService = await SettingsService().init();
  Get.put(settingsService);
  Get.put(SettingsController(Get.find<SettingsService>()));

  // PERF: Lazy-put heavy controllers — they initialize in the background via onInit().
  Get.lazyPut(() => HistoryController(), fenix: true);
  Get.lazyPut(() => QrMakerController(), fenix: true);

  // ── Deferred initialisation ──────────────────────────────────────────────────
  // Initialize MobileAds before running the app to ensure proper ad loading.
  await MobileAds.instance.initialize();
  
  // Mute ads globally. This stops the AdMob SDK from continuously polling
  // the AudioManager for volume changes, which causes log spam on some Android devices.
  MobileAds.instance.setAppMuted(true);
  
  // Preload interstitial
  AdService.loadInterstitialAd();

  runApp(const AiqrApp());
}

/// Root application widget.
class AiqrApp extends StatelessWidget {
  const AiqrApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return GetMaterialApp(
      title: 'Ai Qr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsController.themeMode.value,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      // PERF: Default page transition — faster than the default material animation.
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
