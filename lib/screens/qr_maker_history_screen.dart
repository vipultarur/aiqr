import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/controllers/bottom_nav_controller.dart';
import 'package:aiqr_app/theme/app_theme.dart';
import 'package:aiqr_app/widgets/history_item.dart';
// Removed unused import
import '../controllers/history_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'string_qr_creator_screen.dart';
import 'binary_qr_creator_screen.dart';
import 'all_qr_types_screen.dart';
import 'package:aiqr_app/theme/app_colors.dart';
import '../widgets/banner_ad_widget.dart';

class QrMakerHistoryScreen extends StatelessWidget {
  const QrMakerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    // Removed makerController as it is no longer used
    final HistoryController historyController = Get.find<HistoryController>();

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(Theme.of(context).brightness),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 18,
                bottom: 18,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'aiar QR',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Create and scan QR codes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GSansFlex',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        Get.toNamed('/settings');
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Banner Ad
            const BannerAdWidget(),

            // Main Details (Scrollable)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 120,
                ),

                children: [
                  // Action Grid
                  _buildActionGrid(context),

                  const SizedBox(height: 8),

                  // History Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Recent History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Change the index to 2 to goto history screen
                          Get.find<BottomNavController>().changeIndex(2);
                        },
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
                  ),

                  const SizedBox(height: 8),

                  // History List Items
                  Obx(() {
                    final allHistory = [
                      ...historyController.scannedHistory,
                      ...historyController.generatedHistory
                    ];
                    allHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                    if (allHistory.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No recent QR codes yet.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontFamily: 'GSansFlex',
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Show only 3 of the previous history items
                        ...allHistory.take(3).map((record) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed('/scanResult', arguments: record);
                              },
                              child: HistoryItem(
                                title: record.title ??
                                    (record.type == 'scan'
                                        ? 'Scanned ${record.id.substring(0, 4)}'
                                        : 'Generated ${record.id.substring(0, 4)}'),
                                subtitle: record.data,
                                format: record.format,
                                type: record.type,
                                time: timeago.format(record.timestamp),
                                formatColor:
                                    AppTheme.formatColors[record.format] ??
                                    Colors.orange,
                                typeColor: Colors.blue,
                              ),
                            ),
                          );
                        }),

                        // Text to inform this only shows the last 3 history items
                        if (allHistory.length > 3)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Only the last 3 history items are shown here.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'GSansFlex',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildActionGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildActionButton(context, 'URL', Icons.link, () {
              Get.to(() => const StringQrCreatorScreen(initialType: 'URL'));
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(context, 'PDF', Icons.picture_as_pdf, () {
              Get.to(() => const BinaryQrCreatorScreen(initialType: 'PDF'));
            })),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionButton(context, 'Text', Icons.text_fields, () {
              Get.to(() => const StringQrCreatorScreen(initialType: 'Text'));
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(context, 'Image', Icons.image, () {
              Get.to(() => const BinaryQrCreatorScreen(initialType: 'Image'));
            })),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionButton(context, 'Email', Icons.email, () {
              Get.to(() => const StringQrCreatorScreen(initialType: 'Email'));
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(context, 'All', Icons.apps, () {
              Get.to(() => const AllQrTypesScreen());
            })),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : const Color(0xFFF3F0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[400] : theme.primaryColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
