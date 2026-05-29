import 'package:flutter/material.dart';

/// All named text styles for the app.
///
/// Widget files must not contain inline [TextStyle] — use these instead.
abstract final class AppTextStyles {
  // ── Display / Headline (DMSans Bold) ─────────────────────────────────────────
  static const TextStyle headlineLg = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'GSansFlex',
    fontWeight: FontWeight.normal,
    fontSize: 16,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'GSansFlex',
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: 'GSansFlex',
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: 'GSansFlex',
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: 'GSansFlex',
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static const TextStyle tag = TextStyle(
    fontFamily: 'GSansFlex',
    fontWeight: FontWeight.w600,
    fontSize: 10,
  );

  static const TextStyle scannerTitle = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: Colors.white,
  );

  static const TextStyle scannerSubtitle = TextStyle(
    fontFamily: 'GSansFlex',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: Colors.white70,
  );

  static const TextStyle scannerLabel = TextStyle(
    fontFamily: 'GSansFlex',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: Colors.white,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'GSansFlex',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.white,
  );

  static const TextStyle hint = TextStyle(
    fontFamily: 'GSansFlex',
    fontSize: 14,
    color: Colors.grey,
  );
}
