import 'package:get/get.dart';
import 'package:aiqr_app/features/history/screens/qr_display.dart';
import 'package:aiqr_app/features/main/screens/main_screen.dart';
import 'package:aiqr_app/features/settings/screens/settings_screen.dart';
import 'package:aiqr_app/features/scanner/screens/gallery_scan_screen.dart';
import 'package:aiqr_app/features/main/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String main = '/';
  static const String settings = '/settings';
  static const String qrDisplay = '/qrDisplay';
  static const String galleryScan = '/galleryScan';

  static final routes = [
    GetPage<dynamic>(name: splash, page: () => const SplashScreen()),
    GetPage<dynamic>(name: main, page: () => const MainScreen()),
    GetPage<dynamic>(name: settings, page: () => const SettingsScreen()),
    GetPage<dynamic>(name: qrDisplay, page: () => QrDisplayScreen()),
    GetPage<dynamic>(
      name: galleryScan,
      page: () => GalleryScanScreen(imagePath: Get.arguments as String),
      transition: Transition.fadeIn,
    ),
  ];
}
