import 'package:aiqr_app/features/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/features/main/controllers/bottom_nav_controller.dart';
import 'package:aiqr_app/features/scanner/screens/qr_scanner_screen.dart';
import 'package:aiqr_app/features/history/screens/qr_maker_history_screen.dart';
import 'package:aiqr_app/features/main/widgets/bottom_nav_bar.dart';
import 'package:aiqr_app/features/history/screens/scan_saved_history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Initialize controller
  final BottomNavController controller = Get.put(BottomNavController());

  // PERF: Build pages once and reuse. Using late final so they are created
  // only when the MainScreen is first built, not at import time.
  late final List<Widget> _pages = const [
    QrScannerScreen(),
    QrMakerHistoryScreen(),
    ScanSavedHistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Check for updates on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final SettingsController settingsController =
          Get.find<SettingsController>();
      if (settingsController.autoCheckForUpdates.value) {
        settingsController.checkForUpdates(context, false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(() {
        // PERF: Only show the active page. Prevents hidden platform views
        // (like AdMob BannerAds) from loading in the background.
        // This solves the fatal Android Hybrid Composition log spam crash!
        return _pages[controller.currentIndex.value];
      }),
      floatingActionButton: const BottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
