import 'package:shared_preferences/shared_preferences.dart';
import 'package:aiqr_app/core/constants/storage_keys.dart';

/// Thin wrapper around [SharedPreferences] for reading and writing settings.
///
/// All key strings are defined in [StorageKeys] — never inline them here.
class SettingsService {
  late SharedPreferences _prefs;

  /// Initialises the underlying [SharedPreferences] instance.
  Future<SettingsService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Getters ──────────────────────────────────────────────────────────────────

  /// Returns the stored [ThemeMode] index (0 = system, 1 = light, 2 = dark).
  // PRESERVED: key 'theme_mode'
  int get themeMode => _prefs.getInt(StorageKeys.themeMode) ?? 0;

  /// Whether the scan-beep sound is enabled. Defaults to true.
  // PRESERVED: key 'scan_sounds'
  bool get scanSounds => _prefs.getBool(StorageKeys.scanSounds) ?? true;

  /// Whether device vibration fires on a successful scan. Defaults to true.
  // PRESERVED: key 'haptic_feedback'
  bool get hapticFeedback =>
      _prefs.getBool(StorageKeys.hapticFeedback) ?? true;

  /// Whether scanned data is copied to the clipboard automatically.
  // PRESERVED: key 'auto_copy'
  bool get autoCopy => _prefs.getBool(StorageKeys.autoCopy) ?? false;

  /// Whether the app checks for updates on launch.
  // PRESERVED: key 'auto_check_updates'
  bool get autoCheckUpdates =>
      _prefs.getBool(StorageKeys.autoCheckUpdates) ?? false;

  // ── Setters ──────────────────────────────────────────────────────────────────

  Future<void> setThemeMode(int value) async =>
      _prefs.setInt(StorageKeys.themeMode, value);

  Future<void> setScanSounds(bool value) async =>
      _prefs.setBool(StorageKeys.scanSounds, value);

  Future<void> setHapticFeedback(bool value) async =>
      _prefs.setBool(StorageKeys.hapticFeedback, value);

  Future<void> setAutoCopy(bool value) async =>
      _prefs.setBool(StorageKeys.autoCopy, value);

  Future<void> setAutoCheckUpdates(bool value) async =>
      _prefs.setBool(StorageKeys.autoCheckUpdates, value);
}
