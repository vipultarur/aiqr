import 'package:get/get.dart';
import 'package:aiqr_app/features/history/screens/qr_display.dart';
import 'package:aiqr_app/features/main/screens/main_screen.dart';
import 'package:aiqr_app/features/settings/screens/settings_screen.dart';
import 'package:aiqr_app/features/scanner/screens/gallery_scan_screen.dart';
import 'package:aiqr_app/features/scanner/screens/scan_result_screen.dart';
import 'package:aiqr_app/features/main/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String main = '/';
  static const String settings = '/settings';
  static const String qrDisplay = '/qrDisplay';
  static const String galleryScan = '/galleryScan';
  static const String scanResult = '/scanResult';

  static final routes = [
    GetPage<dynamic>(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 150),
    ),
    GetPage<dynamic>(
      name: main,
      page: () => const MainScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage<dynamic>(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage<dynamic>(
      name: qrDisplay,
      page: () => QrDisplayScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage<dynamic>(
      name: galleryScan,
      page: () => GalleryScanScreen(imagePath: Get.arguments as String),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage<dynamic>(
      name: scanResult,
      page: () => const ScanResultScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
  ];
}
