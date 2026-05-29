import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/core/constants/app_constants.dart';
import 'package:aiqr_app/core/theme/app_dimensions.dart';
import 'package:aiqr_app/features/history/widgets/history_item.dart';
import 'package:aiqr_app/features/history/controllers/history_controller.dart';
import 'package:aiqr_app/features/scanner/widgets/scan_result_bottom_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:aiqr_app/core/theme/app_theme.dart';
import 'package:aiqr_app/routes/app_routes.dart';
import 'package:aiqr_app/core/ads/banner_ad_widget.dart';
import 'package:aiqr_app/models/qr_code_model.dart';

/// History tab: shows scanned and generated QR code records with tab switching.
class ScanSavedHistoryScreen extends StatefulWidget {
  const ScanSavedHistoryScreen({super.key});

  @override
  State<ScanSavedHistoryScreen> createState() => _ScanSavedHistoryScreenState();
}

class _ScanSavedHistoryScreenState extends State<ScanSavedHistoryScreen> {
  bool _isScannedTab = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HistoryHeader(isDark: isDark),
            const BannerAdWidget(),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  // PRESERVED: swipe gesture to switch tabs
                  final velocity = details.primaryVelocity ?? 0;
                  setState(() => _isScannedTab = velocity > 0);
                },
                child: ListView(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.md,
                    right: AppDimensions.md,
                    bottom: AppDimensions.listBottomPadding,
                  ),
                  children: [
                    const SizedBox(height: AppDimensions.md),
                    _TabSelector(
                      isDark: isDark,
                      isScannedTab: _isScannedTab,
                      onScannedTap: () => setState(() => _isScannedTab = true),
                      onGeneratedTap: () =>
                          setState(() => _isScannedTab = false),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    AnimatedSwitcher(
                      duration: AppConstants.animSlow,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: _isScannedTab
                          ? const _HistoryListView(
                              key: ValueKey('scanned'),
                              isScanned: true,
                            )
                          : const _HistoryListView(
                              key: ValueKey('generated'),
                              isScanned: false,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HistoryHeader extends StatelessWidget {
  final bool isDark;
  const _HistoryHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.lg,
        right: AppDimensions.lg,
        top: 18,
        bottom: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Scanned & Generated history',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
              tooltip: 'Settings',
              onPressed: () => Get.toNamed(AppRoutes.settings),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab selector ──────────────────────────────────────────────────────────────

class _TabSelector extends StatelessWidget {
  final bool isDark;
  final bool isScannedTab;
  final VoidCallback onScannedTap;
  final VoidCallback onGeneratedTap;

  const _TabSelector({
    required this.isDark,
    required this.isScannedTab,
    required this.onScannedTap,
    required this.onGeneratedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xs),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'Scanned',
              isSelected: isScannedTab,
              isDark: isDark,
              onTap: onScannedTap,
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Generated',
              isSelected: !isScannedTab,
              isDark: isDark,
              onTap: onGeneratedTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          boxShadow: isSelected && !isDark
              ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'GSansFlex',
              color: isSelected
                  ? Colors.black
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── History list ──────────────────────────────────────────────────────────────

/// Shows either the scanned or generated list using [ListView.builder].
class _HistoryListView extends StatelessWidget {
  final bool isScanned;
  const _HistoryListView({super.key, required this.isScanned});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return Obx(() {
      final records = isScanned
          ? controller.scannedHistory
          : controller.generatedHistory;

      if (records.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: Text(
              isScanned ? 'No scanned items yet.' : 'No generated items yet.',
            ),
          ),
        );
      }

      // Using Column with generated children because the parent ListView
      // already provides the scroll context. ListView.builder would conflict.
      return Column(
        children: List.generate(records.length, (i) {
          final record = records[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
            child: RepaintBoundary(
              child: _RecordTile(record: record),
            ),
          );
        }),
      );
    });
  }
}

class _RecordTile extends StatelessWidget {
  final QrCodeRecord record;
  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.bottomSheet(
        ScanResultBottomSheet(record: record),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      ),
      child: HistoryItem(
        title: record.title ??
            (record.type == 'scan'
                ? 'Scan ${record.id.substring(0, 4)}'
                : 'Generated ${record.id.substring(0, 4)}'),
        subtitle: record.data,
        format: record.format,
        type: record.type,
        time: timeago.format(record.timestamp),
        formatColor: AppTheme.formatColors[record.format] ?? Colors.orange,
        typeColor: Colors.blue,
      ),
    );
  }
}
