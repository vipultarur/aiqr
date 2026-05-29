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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show UI on the first frame, defer heavy init below.
  runApp(const AiarApp());

  // Yield to let the first frame render.
  await Future<void>.delayed(Duration.zero);

  // ── Deferred initialisation ──────────────────────────────────────────────────
  unawaited(MobileAds.instance.initialize());

  final settingsService = await SettingsService().init();
  Get.put(settingsService);
  Get.put(SettingsController(Get.find<SettingsService>()));
  Get.put(HistoryController());
  Get.put(QrMakerController());
}

/// Root application widget.
class AiarApp extends StatelessWidget {
  const AiarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return GetMaterialApp(
      title: 'aiar QR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsController.themeMode.value,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
