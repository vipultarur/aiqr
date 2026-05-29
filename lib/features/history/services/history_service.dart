import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aiqr_app/core/constants/storage_keys.dart';
import 'package:aiqr_app/core/utils/app_logger.dart';
import 'package:aiqr_app/models/qr_code_model.dart';

// ── Top-level functions for compute() ────────────────────────────────────────
// Must be top-level (not closures) to be passed to compute().

// PERF: JSON decoding moved off main thread — history files can grow large.
List<QrCodeRecord> _decodeHistory(String json) {
  final list = jsonDecode(json) as List<dynamic>;
  return list
      .map((e) => QrCodeRecord.fromMap(e as Map<String, dynamic>))
      .toList();
}

// PERF: JSON encoding moved off main thread.
String _encodeHistory(List<QrCodeRecord> records) =>
    jsonEncode(records.map((r) => r.toMap()).toList());

// ─────────────────────────────────────────────────────────────────────────────

/// Persists QR code history as a JSON file in the app's documents directory.
///
/// The file name [StorageKeys.historyFileName] (`'qr_history.json'`) is fixed.
/// Changing it loses all existing user history.
class HistoryService {
  // PRESERVED: file name 'qr_history.json'
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/${StorageKeys.historyFileName}');
  }

  /// Returns the history file reference (used for export).
  Future<File> getHistoryFile() => _file;

  /// Loads all [QrCodeRecord] entries from disk.
  ///
  /// Returns an empty list on any error so callers never receive null.
  Future<List<QrCodeRecord>> loadHistory() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      if (contents.trim().isEmpty) return [];

      // PERF: moved JSON parsing off main thread
      return compute(_decodeHistory, contents);
    } catch (e, st) {
      AppLogger.error('HistoryService.loadHistory', e, st);
      return [];
    }
  }

  /// Persists [history] to disk, replacing any previous data.
  Future<void> saveHistory(List<QrCodeRecord> history) async {
    try {
      final file = await _file;
      // PERF: moved JSON encoding off main thread
      final encoded = await compute(_encodeHistory, history);
      await file.writeAsString(encoded);
    } catch (e, st) {
      AppLogger.error('HistoryService.saveHistory', e, st);
    }
  }

  /// Overwrites the history file with an empty array.
  Future<void> clearHistory() async {
    try {
      final file = await _file;
      await file.writeAsString('[]');
    } catch (e, st) {
      AppLogger.error('HistoryService.clearHistory', e, st);
    }
  }

  /// Removes a single record by [id] from the persisted file.
  Future<void> deleteRecord(String id) async {
    try {
      final history = await loadHistory();
      history.removeWhere((r) => r.id == id);
      await saveHistory(history);
    } catch (e, st) {
      AppLogger.error('HistoryService.deleteRecord', e, st);
    }
  }
}
