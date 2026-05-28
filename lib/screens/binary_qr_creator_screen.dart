import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/qr_maker_controller.dart';
import '../widgets/gradient_button.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BinaryQrCreatorScreen extends StatefulWidget {
  final String initialType;
  
  const BinaryQrCreatorScreen({super.key, required this.initialType});

  @override
  State<BinaryQrCreatorScreen> createState() => _BinaryQrCreatorScreenState();
}

class _BinaryQrCreatorScreenState extends State<BinaryQrCreatorScreen> {
  final QrMakerController controller = Get.put(QrMakerController());
  String? selectedFileName;
  String? selectedFilePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setType(widget.initialType);
    });
  }

  Future<void> _pickFile() async {
    try {
      if (widget.initialType == 'Image') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            selectedFileName = image.name;
            selectedFilePath = image.path;
          });
        }
      } else {
        FilePickerResult? result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            selectedFileName = result.files.single.name;
            selectedFilePath = result.files.single.path;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Create ${widget.initialType} QR'),
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Ad
              const BannerAdWidget(),
              const SizedBox(height: 16),
              
              Text(
                'Upload ${widget.initialType}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // File Picker UI
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedFilePath != null 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selectedFilePath != null 
                            ? Icons.check_circle 
                            : (widget.initialType == 'PDF' ? Icons.picture_as_pdf : Icons.image),
                        size: 64,
                        color: selectedFilePath != null 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          selectedFileName ?? 'Tap to select ${widget.initialType} file',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedFilePath != null 
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.grey[600],
                            fontFamily: 'GSansFlex',
                            fontWeight: selectedFilePath != null ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Input Field (Title)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller.titleController,
                  focusNode: controller.focusNode2,
                  decoration: InputDecoration(
                    icon: Icon(Icons.title, color: Colors.grey[400]),
                    hintText: 'Name your QR',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'GSansFlex',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(
                  () => GradientButton(
                    onPressed: controller.isGenerating.value
                        ? null
                        : () {
                            if (selectedFilePath == null) {
                              Get.snackbar(
                                'File Required',
                                'Please select a ${widget.initialType} file to continue.',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                                colorText: isDark ? Colors.white : Colors.black,
                              );
                              return;
                            }
                            // Using a mock URL incorporating the file name to simulate an uploaded file
                            controller.textController.text = 'https://aiar.app/file/${widget.initialType.toLowerCase()}/${selectedFileName?.replaceAll(' ', '_')}';
                            controller.generateQrCode();
                            controller.focusNode2.unfocus();
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Upload & Generate QR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GSansFlex',
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.upload, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Native Ad
              const NativeAdWidget(templateType: TemplateType.medium),
            ],
          ),
        ),
      ),
    );
  }
}
