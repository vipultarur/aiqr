import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aiqr_app/core/theme/app_theme.dart';
import 'package:aiqr_app/core/widgets/confirmation_bottom_sheet.dart';
import 'package:aiqr_app/features/history/widgets/rename_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:aiqr_app/features/history/controllers/history_controller.dart';
import 'package:aiqr_app/models/qr_code_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:aiqr_app/core/widgets/gradient_button.dart';

class ScanResultScreen extends StatefulWidget {
  final QrCodeRecord? record;
  const ScanResultScreen({super.key, this.record});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  late QrCodeRecord _currentRecord;
  final TextEditingController _nameController = TextEditingController();

  QrCodeRecord get record => _currentRecord;

  @override
  void initState() {
    super.initState();
    // Allow passing via constructor or Get.arguments
    _currentRecord = widget.record ?? Get.arguments as QrCodeRecord;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D15) : Colors.white,
      appBar: AppBar(
        title: const Text('Scan Result', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'GSansFlex')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          _buildTag(
                            record.format,
                            AppTheme.formatColors[record.format] ?? Colors.orange,
                            isDark,
                          ),
                          _buildTag(record.type.toUpperCase(), Colors.blue, isDark),
                          _buildTag(
                            timeago.format(record.timestamp),
                            Colors.green,
                            isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Get.bottomSheet<void>(
                          RenameBottomSheet(
                            nameController: _nameController,
                            title: _currentRecord.title,
                            onConfirm: () async {
                              final newTitle = _nameController.text.trim().isNotEmpty
                                  ? _nameController.text.trim()
                                  : null;

                              final updatedRecord = _currentRecord.copyWith(
                                title: newTitle,
                              );

                              setState(() {
                                _currentRecord = updatedRecord;
                              });

                              if (Get.isRegistered<HistoryController>()) {
                                await Get.find<HistoryController>().updateRecord(
                                  updatedRecord,
                                );
                              }
                              Get.back<void>();
                            },
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                record.title ??
                                    (record.type == 'scan'
                                        ? 'Scan ${record.id.substring(0, 4)}'
                                        : 'Generated ${record.id.substring(0, 4)}'),
                                style: Theme.of(context).textTheme.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit,
                              size: 20,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // QR Image
                GestureDetector(
                  onTap: () {
                    Get.toNamed<void>('/qrDisplay', arguments: record);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 16),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: QrImageView(
                        data: record.data,
                        version: QrVersions.auto,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Link Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey[50],
                border: Border.all(
                  color: isDark
                      ? Colors.grey[800]!.withValues(alpha: 0.5)
                      : Colors.grey[200]!,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: isDark ? 0.3 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForFormat(record.format),
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.data,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLinkSubtext(),
                          style: TextStyle(
                            color: _getLinkSubtextColor(isDark),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy_rounded, color: Colors.grey[400]),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: record.data));
                      Get.snackbar(
                        'Copied',
                        'QR code data copied to clipboard',
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        icon: const Icon(Icons.done_all_rounded),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Cards Grid
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final safetyInfo = _getSafetyInfo();
                      return _buildInfoCard(
                        context,
                        icon: safetyInfo.icon,
                        iconColor: safetyInfo.iconColor,
                        title: safetyInfo.title,
                        subtitle: safetyInfo.subtitle,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    icon: Icons.history_rounded,
                    title: 'History',
                    subtitle: 'Saved to log',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: GradientButton(
                onPressed: record.format == 'URL'
                    ? () async {
                        final uri = Uri.parse(record.data);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            'Could not open URL',
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            icon: const Icon(Icons.error_outline_rounded),
                          );
                        }
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      record.format == 'URL'
                          ? 'Open in Browser'
                          : 'Cannot Open Link',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    context,
                    icon: Icons.cleaning_services_rounded,
                    label: 'Delete',
                    onTap: () {
                      Get.bottomSheet<void>(
                        ConfirmationBottomSheet(
                          header: 'Delete QR Code',
                          message:
                              'Are you sure you want to delete this QR code from history?',
                          onConfirm: () {
                            if (Get.isRegistered<HistoryController>()) {
                              Get.find<HistoryController>().deleteRecord(
                                _currentRecord.id,
                              );
                            }
                            Get.back<void>(); // Close bottom sheet
                            Get.back<void>(); // Close screen
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSecondaryButton(
                    context,
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: () {
                      SharePlus.instance.share(
                        ShareParams(
                          text: record.data,
                          subject: 'Shared via Ai Qr',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? color.withValues(alpha: 0.9) : color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'GSansFlex',
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withValues(alpha: 0.5)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? Colors.grey[400], size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black87),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFormat(String format) {
    switch (format.toLowerCase()) {
      case 'url':
        return Icons.link;
      case 'wi-fi':
        return Icons.wifi;
      case 'contact':
        return Icons.contact_page;
      case 'text':
      default:
        return Icons.text_fields;
    }
  }

  String _getLinkSubtext() {
    if (record.format == 'URL') {
      if (record.data.toLowerCase().startsWith('https://')) {
        return 'Secure Connection • HTTPS';
      } else if (record.data.toLowerCase().startsWith('http://')) {
        return 'Insecure Connection • HTTP';
      }
      return 'Link to visit';
    }
    return 'Raw Data Extract';
  }

  Color _getLinkSubtextColor(bool isDark) {
    if (record.format == 'URL') {
      if (record.data.toLowerCase().startsWith('https://')) {
        return isDark ? Colors.green[400]! : Colors.green[600]!;
      } else if (record.data.toLowerCase().startsWith('http://')) {
        return isDark ? Colors.orange[400]! : Colors.orange[600]!;
      }
    }
    return isDark ? Colors.grey[400]! : Colors.grey[500]!;
  }

  _SafetyInfo _getSafetyInfo() {
    if (record.format == 'URL') {
      final isHttps = record.data.toLowerCase().startsWith('https://');
      if (isHttps) {
        return _SafetyInfo(
          icon: Icons.gpp_good,
          iconColor: Colors.green,
          title: 'Secure',
          subtitle: 'Encrypted traffic',
        );
      } else {
        return _SafetyInfo(
          icon: Icons.gpp_maybe,
          iconColor: Colors.orange,
          title: 'Insecure',
          subtitle: 'Unencrypted traffic',
        );
      }
    } else {
      return _SafetyInfo(
        icon: Icons.offline_pin,
        iconColor: Colors.blue,
        title: 'Offline',
        subtitle: 'No web threats',
      );
    }
  }
}

class _SafetyInfo {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  _SafetyInfo({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}
