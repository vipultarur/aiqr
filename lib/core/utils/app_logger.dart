import 'package:flutter/foundation.dart';

/// App-wide logger. Use this instead of [print] everywhere.
///
/// Output is suppressed in release builds automatically via [kDebugMode].
final class AppLogger {
  const AppLogger._();

  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO] $message');
  }

  static void warning(String message) {
    if (kDebugMode) debugPrint('[WARN] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('  └─ $error');
      if (stackTrace != null) debugPrint('  └─ $stackTrace');
    }
  }
}
