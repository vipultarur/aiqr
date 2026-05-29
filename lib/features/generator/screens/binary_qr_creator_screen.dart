import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aiqr_app/features/generator/controllers/qr_maker_controller.dart';
import 'package:aiqr_app/core/theme/app_dimensions.dart';
import 'package:aiqr_app/core/widgets/gradient_button.dart';
import 'package:aiqr_app/core/ads/banner_ad_widget.dart';
import 'package:aiqr_app/core/ads/native_ad_widget.dart';
import 'package:aiqr_app/core/utils/app_logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Input screen for binary QR types: PDF and Image.
///
/// Shares the [QrMakerController] singleton — never instantiates a new one.
class BinaryQrCreatorScreen extends StatefulWidget {
  final String initialType;
  const BinaryQrCreatorScreen({super.key, required this.initialType});

  @override
  State<BinaryQrCreatorScreen> createState() => _BinaryQrCreatorScreenState();
}

class _BinaryQrCreatorScreenState extends State<BinaryQrCreatorScreen> {
  // BUG FIX: was Get.put() — controller already registered in main.dart
  late final QrMakerController _controller = Get.find<QrMakerController>();

  String? _selectedFileName;
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setType(widget.initialType);
    });
  }

  Future<void> _pickFile() async {
    try {
      if (widget.initialType == 'Image') {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _selectedFileName = image.name;
            _selectedFilePath = image.path;
          });
        }
      } else {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result != null && result.files.single.path != null) {
          setState(() {
            _selectedFileName = result.files.single.name;
            _selectedFilePath = result.files.single.path;
          });
        }
      }
    } catch (e, st) {
      AppLogger.error('BinaryQrCreatorScreen._pickFile', e, st);
      Get.snackbar(
        'Error',
        'Failed to pick file. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void _onGenerate() {
    if (_selectedFilePath == null) {
      Get.snackbar(
        'File Required',
        'Please select a ${widget.initialType} file to continue.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    // PRESERVED: mock URL format that encodes the file reference as a QR payload
    _controller.textController.text =
        'https://aiar.app/file/${widget.initialType.toLowerCase()}/${_selectedFileName?.replaceAll(' ', '_')}';
    _controller.generateQrCode();
    _controller.focusNode2.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasFile = _selectedFilePath != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Create ${widget.initialType} QR'),
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
                'Upload ${widget.initialType}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.lg),
              _FilePickerArea(
                isDark: isDark,
                hasFile: hasFile,
                fileName: _selectedFileName,
                initialType: widget.initialType,
                onTap: _pickFile,
              ),
              const SizedBox(height: AppDimensions.lg),
              _TitleField(controller: _controller, isDark: isDark),
              const SizedBox(height: AppDimensions.xl),
              _UploadButton(controller: _controller, onGenerate: _onGenerate),
              const SizedBox(height: AppDimensions.lg),
              const NativeAdWidget(templateType: TemplateType.medium),
            ],
          ),
        ),
      ),
    );
  }
}

// ── File picker area ──────────────────────────────────────────────────────────

class _FilePickerArea extends StatelessWidget {
  final bool isDark;
  final bool hasFile;
  final String? fileName;
  final String initialType;
  final VoidCallback onTap;

  const _FilePickerArea({
    required this.isDark,
    required this.hasFile,
    required this.fileName,
    required this.initialType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: hasFile
                ? theme.primaryColor
                : Colors.grey.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFile
                  ? Icons.check_circle
                  : (initialType == 'PDF'
                      ? Icons.picture_as_pdf
                      : Icons.image),
              size: 64,
              color: hasFile ? theme.primaryColor : Colors.grey,
            ),
            const SizedBox(height: AppDimensions.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
              child: Text(
                fileName ?? 'Tap to select $initialType file',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: hasFile
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey[600],
                  fontFamily: 'GSansFlex',
                  fontWeight:
                      hasFile ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
          hintStyle:
              TextStyle(color: Colors.grey[400], fontFamily: 'GSansFlex'),
        ),
      ),
    );
  }
}

// ── Upload & generate button ─────────────────────────────────────────────────

class _UploadButton extends StatelessWidget {
  final QrMakerController controller;
  final VoidCallback onGenerate;
  const _UploadButton({required this.controller, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: Obx(() => GradientButton(
        onPressed: controller.isGenerating.value ? null : onGenerate,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Upload & Generate QR',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GSansFlex')),
            SizedBox(width: AppDimensions.sm),
            Icon(Icons.upload, size: 20),
          ],
        ),
      )),
    );
  }
}
