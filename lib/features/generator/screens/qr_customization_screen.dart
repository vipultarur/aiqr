import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:aiqr_app/features/generator/controllers/qr_customization_controller.dart';
import 'package:aiqr_app/models/qr_code_model.dart';
import 'dart:ui';
import 'package:aiqr_app/core/ads/banner_ad_widget.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


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
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
            _buildBottomActionBar(context, controller, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, QrCustomizationController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'GSansFlex')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  foregroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => controller.shareQrCode(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'GSansFlex')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => controller.downloadQrCode(),
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
        // ignore: deprecated_member_use
        shape = PrettyQrRoundedSymbol(
          color: controller.foregroundColor.value,
          borderRadius: BorderRadius.zero,
        );
        break;
      case 'Dots':
        // ignore: deprecated_member_use
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
    // BUG FIX: using controller.contentTextController instead of creating a local
    // TextEditingController that was never disposed (memory leak on every build).
    final textController = controller.contentTextController;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    final format = controller.initialRecord.format;
    
    IconData typeIcon = Icons.link;
    String typeLabel = 'Website URL / Content';
    
    if (format.contains('Email')) {
      typeIcon = Icons.email_rounded;
      typeLabel = 'Email Content';
    } else if (format.contains('Wi-Fi') || format.contains('WIFI')) {
      typeIcon = Icons.wifi_rounded;
      typeLabel = 'Wi-Fi Details';
    } else if (format.contains('Number') || format.contains('Phone')) {
      typeIcon = Icons.phone_rounded;
      typeLabel = 'Phone Number';
    } else if (format.contains('Map') || format.contains('Location')) {
      typeIcon = Icons.map_rounded;
      typeLabel = 'Location Data';
    } else if (format.contains('Text')) {
      typeIcon = Icons.text_fields_rounded;
      typeLabel = 'Text Content';
    } else if (format.contains('Contact') || format.contains('VCard')) {
      typeIcon = Icons.contact_page_rounded;
      typeLabel = 'Contact Details';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (format == 'PDF' || format == 'Image') ...[
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
                color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: isDark ? Theme.of(context).colorScheme.tertiary : const Color(0xFFF3F4F6), width: 2),
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
                      format == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
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
                            : 'Document.${format.toLowerCase()}',
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
                Icon(typeIcon, size: 18, color: isDark ? Colors.grey[400] : primaryColor),
                const SizedBox(width: 8),
                Text(typeLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            _buildInputFields(context, controller, format, isDark, primaryColor, secondaryColor),
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
              color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[200]!),
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

  Widget _buildInputFields(BuildContext context, QrCustomizationController controller, String format, bool isDark, Color primaryColor, Color secondaryColor) {
    if (format.contains('Email')) {
      return Column(
        children: [
          _buildTextField(context, isDark, 'To (Email address)', controller.emailToController, (v) => controller.updateEmailData()),
          const SizedBox(height: 12),
          _buildTextField(context, isDark, 'Subject', controller.emailSubController, (v) => controller.updateEmailData()),
          const SizedBox(height: 12),
          _buildTextField(context, isDark, 'Body Message', controller.emailBodyController, (v) => controller.updateEmailData(), maxLines: 3),
        ],
      );
    } else if (format.contains('Wi-Fi') || format.contains('WIFI')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(context, isDark, 'Network Name (SSID)', controller.wifiSsidController, (v) => controller.updateWifiData()),
          const SizedBox(height: 12),
          _buildTextField(context, isDark, 'Password', controller.wifiPassController, (v) => controller.updateWifiData()),
          const SizedBox(height: 16),
          const Text('Encryption:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Obx(() => SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'WPA/WPA2', label: Text('WPA/WPA2', style: TextStyle(fontSize: 12))),
              ButtonSegment(value: 'WEP', label: Text('WEP', style: TextStyle(fontSize: 12))),
              ButtonSegment(value: 'None', label: Text('None', style: TextStyle(fontSize: 12))),
            ],
            selected: {controller.wifiEnc.value},
            onSelectionChanged: (Set<String> newSelection) {
              controller.wifiEnc.value = newSelection.first;
              controller.updateWifiData();
            },
          )),
        ],
      );
    } else if (format.contains('Number') || format.contains('Phone')) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[200]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: IntlPhoneField(
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Phone Number',
            hintStyle: TextStyle(color: Colors.grey),
          ),
          initialCountryCode: 'US',
          initialValue: controller.phoneController.text.startsWith('+') ? controller.phoneController.text : null,
          dropdownIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          dropdownTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
          pickerDialogStyle: PickerDialogStyle(
            backgroundColor: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            countryCodeStyle: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            countryNameStyle: TextStyle(color: isDark ? Colors.white : Colors.black87, fontFamily: 'GSansFlex'),
            searchFieldCursorColor: primaryColor,
            searchFieldInputDecoration: InputDecoration(
              hintText: 'Search Country',
              hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'GSansFlex'),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              filled: true,
              fillColor: isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          onChanged: (phone) {
            controller.phoneController.text = phone.completeNumber;
            controller.updatePhoneData();
          },
        ),
      );
    } else if (format.contains('Map') || format.contains('Location')) {
      return Column(
        children: [
          _buildTextField(context, isDark, 'Latitude', controller.mapLatController, (v) => controller.updateMapData()),
          const SizedBox(height: 12),
          _buildTextField(context, isDark, 'Longitude', controller.mapLngController, (v) => controller.updateMapData()),
          const SizedBox(height: 12),
          _buildTextField(context, isDark, 'Or Google Maps Link', controller.mapLinkController, (v) => controller.updateMapData()),
        ],
      );
    } else {
      // Default Generic Fields
      return _buildTextFieldWithPaste(context, isDark, primaryColor, secondaryColor, controller.contentTextController, (v) => controller.updateData(v), maxLines: format.contains('Text') || format.contains('Contact') ? 3 : 1);
    }
  }

  Widget _buildTextField(BuildContext context, bool isDark, String hint, TextEditingController textController, Function(String) onChanged, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: textController,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTextFieldWithPaste(BuildContext context, bool isDark, Color primaryColor, Color secondaryColor, TextEditingController textController, Function(String) onChanged, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[200]!),
      ),
      padding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              onChanged: onChanged,
              maxLines: maxLines,
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
                onChanged(data.text!);
              }
            },
            icon: Icon(Icons.paste, size: 16, color: primaryColor),
            label: Text('Paste', style: TextStyle(color: primaryColor)),
            style: TextButton.styleFrom(
              backgroundColor: isDark ? Theme.of(context).colorScheme.tertiary : secondaryColor.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[200]!),
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
          Row(
            children: [
              _buildShapeOption(context, controller, 'Smooth', Icons.water_drop_outlined),
              const SizedBox(width: 12),
              _buildShapeOption(context, controller, 'Dots', Icons.blur_on),
              const SizedBox(width: 12),
              _buildShapeOption(context, controller, 'Squares', Icons.grid_view_rounded),
            ],
          ),
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
              // Custom Color Picker
              GestureDetector(
                onTap: () => _showColorPicker(context, controller.foregroundColor),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[400]!, width: 2, style: BorderStyle.solid),
                  ),
                  child: Icon(Icons.colorize, color: Colors.grey[600]),
                ),
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
              // Custom Color Picker for Background
              GestureDetector(
                onTap: () => _showColorPicker(context, controller.backgroundColor),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[400]!, width: 2, style: BorderStyle.solid),
                  ),
                  child: Icon(Icons.colorize, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, Rx<Color> targetColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA),
          shape: const TooltipShapeBorder(radius: 16),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: targetColor.value,
                  onColorChanged: (Color color) {
                    targetColor.value = color; // Live updates
                  },
                  enableAlpha: true,
                  displayThumbColor: true,
                  labelTypes: const [], // Hides HEX/RGB text labels to match image
                  paletteType: PaletteType.hsvWithHue,
                  pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(12)),
                  colorPickerWidth: 280,
                  pickerAreaHeightPercent: 0.8,
                  colorHistory: const [
                    Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFF59E0B), Color(0xFF84CC16),
                    Color(0xFF22C55E), Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF6366F1),
                    Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFF64748B), Color(0xFF1E293B),
                    Colors.black, Colors.white,
                  ],
                  onHistoryChanged: (List<Color> colors) {
                    if (colors.isNotEmpty) {
                      targetColor.value = colors.last;
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
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
          Row(
            children: [
              _buildEcOption(context, controller, QrErrorCorrectLevel.L, 'L', '7%'),
              const SizedBox(width: 8),
              _buildEcOption(context, controller, QrErrorCorrectLevel.M, 'M', '15%'),
              const SizedBox(width: 8),
              _buildEcOption(context, controller, QrErrorCorrectLevel.Q, 'Q', '25%'),
              const SizedBox(width: 8),
              _buildEcOption(context, controller, QrErrorCorrectLevel.H, 'H', '30%'),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Export Image Resolution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          _buildResolutionOption(context, controller, 256, 'Low Quality', '256 x 256 px - Fast rendering', Icons.sd),
          _buildResolutionOption(context, controller, 512, 'Standard Quality', '512 x 512 px - Good for digital', Icons.hd),
          _buildResolutionOption(context, controller, 1024, 'High Quality', '1024 x 1024 px - Best for printing', Icons.high_quality),
        ],
      ),
    );
  }

  Widget _buildShapeOption(BuildContext context, QrCustomizationController controller, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Obx(() {
        final isSelected = controller.shapeStyle.value == value;
        return GestureDetector(
          onTap: () => controller.shapeStyle.value = value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : (isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[100]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected && !isDark ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Column(
              children: [
                Icon(icon, color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]), size: 24),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEcOption(BuildContext context, QrCustomizationController controller, int value, String label, String desc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Obx(() {
        final isSelected = controller.errorCorrectionLevel.value == value;
        return GestureDetector(
          onTap: () => controller.errorCorrectionLevel.value = value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : (isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[100]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResolutionOption(BuildContext context, QrCustomizationController controller, int value, String title, String subtitle, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final isSelected = controller.exportSize.value == value;
      return GestureDetector(
        onTap: () => controller.exportSize.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : (isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[200]!),
              width: 2,
            ),
            boxShadow: isSelected && !isDark ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : (isDark ? Theme.of(context).colorScheme.tertiary : Colors.grey[100]),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                    Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      );
    });
  }
}

// Custom Shape for the Dialog to mimic the tooltip tail in the design
class TooltipShapeBorder extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double radius;

  const TooltipShapeBorder({
    this.arrowWidth = 20.0,
    this.arrowHeight = 12.0,
    this.radius = 16.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight - Offset(0, arrowHeight));
    double x = arrowWidth;
    double y = arrowHeight;
    double r = radius;

    return Path()
      ..moveTo(rect.left + r, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + r), radius: Radius.circular(r))
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(Offset(rect.right - r, rect.bottom), radius: Radius.circular(r))
      ..lineTo(rect.bottomCenter.dx + x / 2, rect.bottom)
      ..lineTo(rect.bottomCenter.dx, rect.bottom + y)
      ..lineTo(rect.bottomCenter.dx - x / 2, rect.bottom)
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - r), radius: Radius.circular(r))
      ..lineTo(rect.left, rect.top + r)
      ..arcToPoint(Offset(rect.left + r, rect.top), radius: Radius.circular(r))
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
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
