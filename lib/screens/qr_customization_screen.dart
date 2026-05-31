import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';
import '../controllers/qr_customization_controller.dart';
import '../models/qr_code_model.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../widgets/banner_ad_widget.dart';

class QrCustomizationScreen extends StatelessWidget {
  final QrCodeRecord record;

  const QrCustomizationScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QrCustomizationController(initialRecord: record));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text('Customize QR', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: bgColor,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Banner Ad
            const BannerAdWidget(),

            // Fixed QR Code Preview Area at the top
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: RepaintBoundary(
                  key: controller.qrKey,
                  child: Obx(() {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: controller.backgroundColor.value,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                        ],
                      ),
                      child: _buildQrPreview(controller),
                    );
                  }),
                ),
              ),
            ),
            
            // Styled Pill Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? Colors.grey[400] : primaryColor,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(text: 'Content'),
                  Tab(text: 'Logo'),
                  Tab(text: 'Color'),
                  Tab(text: 'Export'),
                ],
              ),
            ),
            
            // Scrollable Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildContentTab(context, controller),
                  _buildLogoTab(context, controller),
                  _buildDesignTab(context, controller),
                  _buildExportTab(context, controller),
                ],
              ),
            ),
            
            // Common Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.shareQrCode(),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'GSansFlex')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primaryColor, width: 2),
                          foregroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.downloadQrCode(),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'GSansFlex')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
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

  Widget _buildQrPreview(QrCustomizationController controller) {
    if (controller.data.value.isEmpty) {
      return const SizedBox(
        width: 180,
        height: 180,
        child: Center(child: Text('No data')),
      );
    }
    
    final qrCode = QrCode.fromData(
      data: controller.data.value,
      errorCorrectLevel: controller.errorCorrectionLevel.value,
    );

    PrettyQrShape shape;
    switch (controller.shapeStyle.value) {
      case 'Squares':
        shape = PrettyQrRoundedSymbol(
          color: controller.foregroundColor.value,
          borderRadius: BorderRadius.zero,
        );
        break;
      case 'Dots':
        shape = PrettyQrRoundedSymbol(
          color: controller.foregroundColor.value,
          borderRadius: const BorderRadius.all(Radius.circular(100)),
        );
        break;
      case 'Smooth':
      default:
        shape = PrettyQrSmoothSymbol(color: controller.foregroundColor.value);
        break;
    }

    final logoPosition = controller.logoPosition.value == 'Embedded' 
        ? PrettyQrDecorationImagePosition.embedded 
        : PrettyQrDecorationImagePosition.foreground;

    return SizedBox(
      width: 180,
      height: 180,
      child: PrettyQrView(
        qrImage: QrImage(qrCode),
        decoration: PrettyQrDecoration(
          shape: shape,
          image: controller.logoPath.value.isNotEmpty
              ? PrettyQrDecorationImage(
                  image: FileImage(File(controller.logoPath.value)),
                  position: logoPosition,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildContentTab(BuildContext context, QrCustomizationController controller) {
    final TextEditingController textController = TextEditingController(text: controller.data.value);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.initialRecord.type == 'PDF' || controller.initialRecord.type == 'Image') ...[
            Row(
              children: [
                Icon(Icons.insert_drive_file, size: 18, color: isDark ? Colors.grey[400] : primaryColor),
                const SizedBox(width: 8),
                const Text('File Uploaded', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFF3F4F6), width: 2),
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Row(
                children: [
                  // Leading Icon Circle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E8FF), // Light purple bg
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.initialRecord.type == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                      color: const Color(0xFFA855F7), // Purple color
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // File details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.initialRecord.title?.isNotEmpty == true 
                            ? controller.initialRecord.title! 
                            : 'Document.${controller.initialRecord.type.toLowerCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 18, 
                            color: isDark ? Colors.white : Colors.black87,
                            fontFamily: 'GSansFlex'
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '2.4 MB',
                          style: TextStyle(color: Color(0xFFC4B5FD), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  
                  // Trailing Action Icons
                  const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF22C55E), size: 30), // Green checkmark
                  const SizedBox(width: 16),
                  const Icon(Icons.delete_outline_rounded, color: Color(0xFFD8B4FE), size: 30), // Light purple trash
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.link, size: 18, color: isDark ? Colors.grey[400] : primaryColor),
                const SizedBox(width: 8),
                const Text('Website URL / Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
              ),
              padding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (val) => controller.updateData(val),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter QR content...',
                        isDense: true,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        textController.text = data!.text!;
                        controller.updateData(data.text!);
                      }
                    },
                    icon: Icon(Icons.paste, size: 16, color: primaryColor),
                    label: Text('Paste', style: TextStyle(color: primaryColor)),
                    style: TextButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey[800] : secondaryColor.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Icon(Icons.label_outline, size: 18, color: isDark ? Colors.grey[400] : primaryColor),
              const SizedBox(width: 8),
              const Text('QR Title (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: const TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'e.g. Portfolio Page',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoTab(BuildContext context, QrCustomizationController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_file, size: 18, color: isDark ? Colors.grey[400] : primaryColor),
              const SizedBox(width: 8),
              const Text('File Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.logoPath.value.isNotEmpty) {
              final fileName = controller.logoPath.value.split('/').last;
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const Text('Uploaded', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => controller.removeLogo(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Position:', style: TextStyle(fontWeight: FontWeight.w600)),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Embedded', label: Text('Embedded')),
                          ButtonSegment(value: 'Foreground', label: Text('Overlay')),
                        ],
                        selected: {controller.logoPosition.value},
                        onSelectionChanged: (Set<String> newSelection) {
                          controller.logoPosition.value = newSelection.first;
                        },
                      ),
                    ],
                  ),
                ],
              );
            }
            return GestureDetector(
              onTap: () => controller.pickLogo(),
              child: CustomPaint(
                painter: DashedRectPainter(color: secondaryColor),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: secondaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, color: primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Text('Upload logo', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDesignTab(BuildContext context, QrCustomizationController controller) {
    final primaryColor = Theme.of(context).primaryColor;
    
    final List<Color> availableForegrounds = [
      primaryColor, Colors.black, const Color(0xFFEF4444), 
      const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B)
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shape Style', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Obx(() => SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Smooth', label: Text('Smooth')),
              ButtonSegment(value: 'Dots', label: Text('Dots')),
              ButtonSegment(value: 'Squares', label: Text('Squares')),
            ],
            selected: {controller.shapeStyle.value},
            onSelectionChanged: (Set<String> newSelection) {
              controller.shapeStyle.value = newSelection.first;
            },
          )),
          const SizedBox(height: 24),
          const Text('QR Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ...availableForegrounds.map((color) {
                return Obx(() {
                  final isSelected = controller.foregroundColor.value == color;
                  return GestureDetector(
                    onTap: () => controller.foregroundColor.value = color,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: color.withValues(alpha: 0.5), width: 3) : Border.all(color: Colors.transparent, width: 3),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                });
              }),
              // Custom Color Picker Placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[400]!, width: 2, style: BorderStyle.solid),
                ),
                child: Icon(Icons.add, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Background Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ...[Colors.white, const Color(0xFFF3F4F6), const Color(0xFFFEF2F2), const Color(0xFFF0FDF4)].map((color) {
                return Obx(() {
                  final isSelected = controller.backgroundColor.value == color;
                  return GestureDetector(
                    onTap: () => controller.backgroundColor.value = color,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.blueAccent, width: 3) : Border.all(color: Colors.grey[300]!, width: 1),
                        color: color,
                      ),
                    ),
                  );
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportTab(BuildContext context, QrCustomizationController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Error Correction Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Higher levels make the QR code denser but more resilient to damage. Recommended when using a logo.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Obx(() => SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: QrErrorCorrectLevel.L, label: Text('L (7%)')),
              ButtonSegment(value: QrErrorCorrectLevel.M, label: Text('M (15%)')),
              ButtonSegment(value: QrErrorCorrectLevel.Q, label: Text('Q (25%)')),
              ButtonSegment(value: QrErrorCorrectLevel.H, label: Text('H (30%)')),
            ],
            selected: {controller.errorCorrectionLevel.value},
            onSelectionChanged: (Set<int> newSelection) {
              controller.errorCorrectionLevel.value = newSelection.first;
            },
          )),
          const SizedBox(height: 32),
          const Text('Export Image Resolution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            value: controller.exportSize.value,
            items: const [
              DropdownMenuItem(value: 256, child: Text('256 x 256 px')),
              DropdownMenuItem(value: 512, child: Text('512 x 512 px (Standard)')),
              DropdownMenuItem(value: 1024, child: Text('1024 x 1024 px (High Quality)')),
            ],
            onChanged: (val) => controller.exportSize.value = val!,
          )),
        ],
      ),
    );
  }
}

// Custom Painter for dashed border
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;

  DashedRectPainter({required this.color, this.strokeWidth = 2.0, this.gap = 5.0, this.dash = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(24));
    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        double length = draw ? dash : gap;
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
