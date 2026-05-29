import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/features/generator/controllers/qr_maker_controller.dart';
import 'package:aiqr_app/core/theme/app_dimensions.dart';
import 'package:aiqr_app/core/widgets/gradient_button.dart';
import 'package:aiqr_app/core/ads/banner_ad_widget.dart';
import 'package:aiqr_app/core/ads/native_ad_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Input screen for string-based QR types: URL, Text, Email, Wi-Fi, Number, Map.
///
/// Shares the [QrMakerController] singleton — never instantiates a new one.
class StringQrCreatorScreen extends StatelessWidget {
  final String initialType;
  const StringQrCreatorScreen({super.key, required this.initialType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // BUG FIX: was Get.put() — controller already registered in main.dart
    final controller = Get.find<QrMakerController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialType != 'All') controller.setType(initialType);
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Create $initialType QR'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerAdWidget(),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Enter Details',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.lg),
              _InputFields(
                initialType: initialType,
                controller: controller,
                isDark: isDark,
              ),
              _TitleField(controller: controller, isDark: isDark),
              const SizedBox(height: AppDimensions.xl),
              _GenerateButton(controller: controller),
              const SizedBox(height: AppDimensions.lg),
              const NativeAdWidget(templateType: TemplateType.medium),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Input fields factory ───────────────────────────────────────────────────────

class _InputFields extends StatelessWidget {
  final String initialType;
  final QrMakerController controller;
  final bool isDark;

  const _InputFields({
    required this.initialType,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (initialType == 'Email') return _EmailFields(c: controller, isDark: isDark);
    if (initialType == 'Wi-Fi') return _WifiFields(c: controller, isDark: isDark);
    if (initialType == 'Number') return _NumberFields(c: controller, isDark: isDark);
    if (initialType == 'Map') return _MapFields(c: controller, isDark: isDark);
    return _GenericField(c: controller, isDark: isDark);
  }
}

// ── Email ────────────────────────────────────────────────────────────────────

class _EmailFields extends StatelessWidget {
  final QrMakerController c;
  final bool isDark;
  const _EmailFields({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TextField(controller: c.emailController, hint: 'Email Address', icon: Icons.email, isDark: isDark),
        const SizedBox(height: AppDimensions.md),
        _TextField(controller: c.subjectController, hint: 'Subject', icon: Icons.subject, isDark: isDark),
        const SizedBox(height: AppDimensions.md),
        _TextField(controller: c.bodyController, hint: 'Body', icon: Icons.message, isDark: isDark, maxLines: 4),
        const SizedBox(height: AppDimensions.md),
      ],
    );
  }
}

// ── Wi-Fi ────────────────────────────────────────────────────────────────────

class _WifiFields extends StatelessWidget {
  final QrMakerController c;
  final bool isDark;
  const _WifiFields({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TextField(controller: c.ssidController, hint: 'Network Name (SSID)', icon: Icons.wifi, isDark: isDark),
        const SizedBox(height: AppDimensions.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: c.wifiEncryption.value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
              // PRESERVED: Wi-Fi encryption options
              items: ['WPA/WPA2', 'WPA3', 'WEP', 'None', 'Raw']
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontFamily: 'GSansFlex',
                            )),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) c.wifiEncryption.value = v;
              },
            ),
          )),
        ),
        const SizedBox(height: AppDimensions.md),
        _TextField(controller: c.passwordController, hint: 'Password', icon: Icons.lock, isDark: isDark),
        const SizedBox(height: AppDimensions.md),
      ],
    );
  }
}

// ── Phone number ─────────────────────────────────────────────────────────────

class _NumberFields extends StatelessWidget {
  final QrMakerController c;
  final bool isDark;
  const _NumberFields({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _TextField(
                controller: c.countryCodeController,
                hint: 'Code',
                icon: Icons.public,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              flex: 3,
              child: _TextField(
                controller: c.numberController,
                hint: 'Phone Number',
                icon: Icons.phone,
                isDark: isDark,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
      ],
    );
  }
}

// ── Map ───────────────────────────────────────────────────────────────────────

class _MapFields extends StatelessWidget {
  final QrMakerController c;
  final bool isDark;
  const _MapFields({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TextField(controller: c.mapLinkController, hint: 'Google Map Link', icon: Icons.map, isDark: isDark),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.sm),
          child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Row(
          children: [
            Expanded(
              child: _TextField(
                controller: c.latController,
                hint: 'Latitude',
                icon: Icons.location_on,
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: _TextField(
                controller: c.lngController,
                hint: 'Longitude',
                icon: Icons.location_on,
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
      ],
    );
  }
}

// ── Generic (URL / Text) ──────────────────────────────────────────────────────

class _GenericField extends StatelessWidget {
  final QrMakerController c;
  final bool isDark;
  const _GenericField({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TextField(
          controller: c.textController,
          hint: 'Enter QR content',
          icon: Icons.edit,
          isDark: isDark,
          maxLines: null,
          focusNode: c.focusNode1,
        ),
        const SizedBox(height: AppDimensions.md),
      ],
    );
  }
}

// ── Shared text field ─────────────────────────────────────────────────────────

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final int? maxLines;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;

  const _TextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.maxLines = 1,
    this.focusNode,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md, vertical: AppDimensions.xs),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        keyboardType: keyboardType ??
            (maxLines == null ? TextInputType.multiline : TextInputType.text),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey[400]),
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'GSansFlex'),
        ),
      ),
    );
  }
}

// ── Title field ───────────────────────────────────────────────────────────────

class _TitleField extends StatelessWidget {
  final QrMakerController controller;
  final bool isDark;
  const _TitleField({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md, vertical: AppDimensions.xs),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TextField(
        controller: controller.titleController,
        focusNode: controller.focusNode2,
        decoration: InputDecoration(
          icon: Icon(Icons.title, color: Colors.grey[400]),
          hintText: 'Name your QR',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'GSansFlex'),
        ),
      ),
    );
  }
}

// ── Generate button ───────────────────────────────────────────────────────────

class _GenerateButton extends StatelessWidget {
  final QrMakerController controller;
  const _GenerateButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: Obx(() => GradientButton(
        onPressed: controller.isGenerating.value
            ? null
            : () {
                controller.generateQrCode();
                controller.focusNode1.unfocus();
                controller.focusNode2.unfocus();
              },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Generate QR',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GSansFlex')),
            SizedBox(width: AppDimensions.sm),
            Icon(Icons.qr_code, size: 20),
          ],
        ),
      )),
    );
  }
}
