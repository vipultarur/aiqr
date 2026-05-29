// ── Storage Keys ──────────────────────────────────────────────────────────────
// PRESERVED: These exact string values are persisted on-device.
// Never rename them — doing so silently loses all user settings and history.
// ─────────────────────────────────────────────────────────────────────────────

/// Keys used with [SharedPreferences] for persistent settings.
abstract final class StorageKeys {
  // ── SharedPreferences keys ──────────────────────────────────────────────────
  static const String themeMode = 'theme_mode';
  static const String scanSounds = 'scan_sounds';
  static const String hapticFeedback = 'haptic_feedback';
  static const String autoCopy = 'auto_copy';
  static const String autoCheckUpdates = 'auto_check_updates';

  // ── File-system keys ────────────────────────────────────────────────────────
  /// JSON file that stores all scan / generate history records.
  static const String historyFileName = 'qr_history.json';

  // ── QrCodeRecord field values ────────────────────────────────────────────────
  // PRESERVED: These strings are written into every stored record.
  // Changing them breaks existing history deserialization.
  static const String typeScan = 'scan';
  static const String typeGenerate = 'generate';
}
