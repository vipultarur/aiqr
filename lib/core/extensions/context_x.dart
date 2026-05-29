import 'package:flutter/material.dart';
import 'package:aiqr_app/routes/app_routes.dart';

/// Navigation extension on [BuildContext].
///
/// Keeps widget code free of raw `Get.toNamed` / `Navigator.pushNamed` calls
/// and ensures all route strings come from [AppRoutes] constants.
extension NavigationX on BuildContext {
  /// Push the settings screen.
  void goSettings() => _goNamed(AppRoutes.settings);

  /// Push the QR display screen with a [QrCodeRecord] argument.
  void goQrDisplay(Object args) => _goNamed(AppRoutes.qrDisplay, args: args);

  /// Push the gallery scan screen with an image-path [String] argument.
  void goGalleryScan(String imagePath) =>
      _goNamed(AppRoutes.galleryScan, args: imagePath);

  // ── Internal helpers ─────────────────────────────────────────────────────────

  void _goNamed(String route, {Object? args}) {
    // GetX is the navigation layer; we call it through context to stay
    // compatible if Navigator is ever needed.
    Navigator.of(this).pushNamed(route, arguments: args);
  }
}
