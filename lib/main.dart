import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/controllers/qr_maker_controller.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'controllers/history_controller.dart';
import 'services/settings_service.dart';
import 'controllers/settings_controller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  // Initialize and inject Settings Service
  final settingsService = await SettingsService().init();
  Get.put(settingsService);

  // Initialize Settings Controller
  Get.put(SettingsController(Get.find<SettingsService>()));

  // Initialize History Controllers
  Get.put(HistoryController());

  // Initialize QR Maker Controller
  Get.put(QrMakerController());

  runApp(const aiarApp());
}

class aiarApp extends StatelessWidget {
  const aiarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController =
        Get.find<SettingsController>();

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
