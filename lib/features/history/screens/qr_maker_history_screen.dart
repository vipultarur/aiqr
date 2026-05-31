import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/features/main/controllers/bottom_nav_controller.dart';
import 'package:aiqr_app/core/constants/app_constants.dart';
import 'package:aiqr_app/core/theme/app_colors.dart';
import 'package:aiqr_app/core/theme/app_dimensions.dart';
import 'package:aiqr_app/core/theme/app_theme.dart';
import 'package:aiqr_app/features/history/widgets/history_item.dart';
import 'package:aiqr_app/features/history/controllers/history_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:aiqr_app/features/generator/screens/string_qr_creator_screen.dart';
import 'package:aiqr_app/features/generator/screens/all_qr_types_screen.dart';
import 'package:aiqr_app/routes/app_routes.dart';
import 'package:aiqr_app/core/ads/banner_ad_widget.dart';
import 'package:aiqr_app/models/qr_code_model.dart';

/// Home / Make tab: action grid + recent history preview.
class QrMakerHistoryScreen extends StatelessWidget {
  const QrMakerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final historyController = Get.find<HistoryController>();

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(theme.brightness),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _HomeHeader(isDark: isDark),
              const BannerAdWidget(),
              const SizedBox(height: AppDimensions.md),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.lg,
                    right: AppDimensions.lg,
                    bottom: AppDimensions.listBottomPadding,
                  ),
                  children: [
                    _ActionGrid(isDark: isDark),
                    const SizedBox(height: AppDimensions.sm),
                    _RecentHistoryHeader(isDark: isDark),
                    const SizedBox(height: AppDimensions.sm),
                    _RecentHistoryList(
                      historyController: historyController,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final bool isDark;
  const _HomeHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ai Qr',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Create and scan QR codes',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          _SettingsButton(isDark: isDark),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final bool isDark;
  const _SettingsButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.settings, color: Theme.of(context).primaryColor),
        tooltip: 'Settings',
        onPressed: () => Get.toNamed(AppRoutes.settings),
      ),
    );
  }
}

// ── Recent history header row ────────────────────────────────────────────────

class _RecentHistoryHeader extends StatelessWidget {
  final bool isDark;
  const _RecentHistoryHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent History',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => Get.find<BottomNavController>().changeIndex(2),
          child: Text(
            'View All',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontFamily: 'GSansFlex',
            ),
          ),
        ),
      ],
    );
  }
}

// ── Recent history list ───────────────────────────────────────────────────────

class _RecentHistoryList extends StatelessWidget {
  final HistoryController historyController;
  final bool isDark;

  const _RecentHistoryList({
    required this.historyController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allHistory = [
        ...historyController.scannedHistory,
        ...historyController.generatedHistory,
      ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (allHistory.isEmpty) {
        return const _EmptyHistoryMessage();
      }

      final preview = allHistory.take(AppConstants.homeHistoryPreviewCount).toList();

      return Column(
        children: [
          ...List.generate(preview.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: RepaintBoundary(
                child: _HistoryTile(record: preview[i]),
              ),
            );
          }),
          if (allHistory.length > AppConstants.homeHistoryPreviewCount)
            const Padding(
              padding: EdgeInsets.only(top: AppDimensions.sm),
              child: Text(
                'Only the last 3 history items are shown here.',
                style: TextStyle(color: Colors.grey, fontFamily: 'GSansFlex'),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    });
  }
}

class _EmptyHistoryMessage extends StatelessWidget {
  const _EmptyHistoryMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
      child: Center(
        child: Text(
          'No recent QR codes yet.',
          style: TextStyle(color: Colors.grey[500], fontFamily: 'GSansFlex'),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final QrCodeRecord record;
  const _HistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/scanResult', arguments: record),
      child: HistoryItem(
        title: record.title ??
            (record.type == 'scan'
                ? 'Scanned ${record.id.substring(0, 4)}'
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

// ── Action grid ───────────────────────────────────────────────────────────────

class _ActionGrid extends StatelessWidget {
  final bool isDark;
  const _ActionGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                isDark: isDark,
                title: 'URL',
                icon: Icons.link,
                onTap: () => Get.to(
                  () => const StringQrCreatorScreen(initialType: 'URL'),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: _ActionButton(
                isDark: isDark,
                title: 'Wi-Fi',
                icon: Icons.wifi,
                onTap: () => Get.to(
                  () => const StringQrCreatorScreen(initialType: 'Wi-Fi'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                isDark: isDark,
                title: 'Text',
                icon: Icons.text_fields,
                onTap: () => Get.to(
                  () => const StringQrCreatorScreen(initialType: 'Text'),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: _ActionButton(
                isDark: isDark,
                title: 'Number',
                icon: Icons.phone,
                onTap: () => Get.to(
                  () => const StringQrCreatorScreen(initialType: 'Number'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                isDark: isDark,
                title: 'Email',
                icon: Icons.email,
                onTap: () => Get.to(
                  () => const StringQrCreatorScreen(initialType: 'Email'),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: _ActionButton(
                isDark: isDark,
                title: 'All',
                icon: Icons.apps,
                onTap: () => Get.to(() => const AllQrTypesScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A single tappable quick-action button on the home grid.
class _ActionButton extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.tertiary
                    : theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.primaryColor, size: AppDimensions.iconLg),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.tertiary
                    : const Color(0xFFF3F0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[400] : theme.primaryColor,
                size: AppDimensions.iconMd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
