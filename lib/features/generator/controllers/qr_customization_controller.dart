import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr/qr.dart';
import 'package:aiqr_app/models/qr_code_model.dart';
import 'package:aiqr_app/features/history/controllers/history_controller.dart';
import 'package:aiqr_app/core/ads/ad_service.dart';

class QrCustomizationController extends GetxController {
  final QrCodeRecord initialRecord;
  final GlobalKey qrKey = GlobalKey();
  final HistoryController _historyController = Get.find();

  // Customization States
  var data = ''.obs;
  var logoPath = ''.obs;
  var foregroundColor = Colors.black.obs;
  var backgroundColor = Colors.white.obs;
  var errorCorrectionLevel = QrErrorCorrectLevel.M.obs;
  
  // New customization options
  var shapeStyle = 'Smooth'.obs; // Smooth, Squares, Dots
  var logoPosition = 'Embedded'.obs; // Embedded, Overlay
  var exportSize = 512.obs; // 256, 512, 1024

  QrCustomizationController({required this.initialRecord});

  // BUG FIX: TextEditingController for the content tab — was created inline on
  // every build cycle in the screen, causing a memory leak per rebuild.
  late final TextEditingController contentTextController =
      TextEditingController(text: initialRecord.data);

  @override
  void onInit() {
    super.onInit();
    data.value = initialRecord.data;
  }

  @override
  void onClose() {
    contentTextController.dispose();
    super.onClose();
  }

  void updateData(String newData) {
    data.value = newData;
    _updateHistory();
  }

  void _updateHistory() {
    final updatedRecord = initialRecord.copyWith(data: data.value);
    _historyController.updateRecord(updatedRecord);
  }

  Future<void> pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      logoPath.value = image.path;
      // When a logo is added, error correction should ideally be high to ensure readability
      errorCorrectionLevel.value = QrErrorCorrectLevel.H;
    }
  }

  void removeLogo() {
    logoPath.value = '';
  }

  // Helper method to capture QR code
  Future<Uint8List?> _captureQrImage() async {
    try {
      // Small delay to ensure rendering is complete
      await Future.delayed(const Duration(milliseconds: 100));
      RenderRepaintBoundary boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // Calculate pixel ratio to hit exactly the desired export size
      // The preview container is exactly 232x232 logical pixels (200 QR + 16 padding on each side)
      double pixelRatio = exportSize.value / 232.0;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture QR code image.');
      return null;
    }
  }

  Future<void> downloadQrCode() async {
    AdService.showInterstitialAd(onAdDismissed: () async {
      final bytes = await _captureQrImage();
      if (bytes != null) {
        final result = await ImageGallerySaverPlus.saveImage(bytes, name: 'QR_${DateTime.now().millisecondsSinceEpoch}');
        if (result != null && result['isSuccess'] == true) {
          Get.snackbar('Success', 'QR Code saved to gallery!', snackPosition: SnackPosition.TOP);
        } else {
          Get.snackbar('Error', 'Failed to save QR code.', snackPosition: SnackPosition.TOP);
        }
      }
    });
  }

  Future<void> shareQrCode() async {
    AdService.showInterstitialAd(onAdDismissed: () async {
      final bytes = await _captureQrImage();
      if (bytes != null) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/shared_qr.png');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Here is my customized QR Code!');
      }
    });
  }
}
