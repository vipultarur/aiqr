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
import 'package:in_app_review/in_app_review.dart';

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

  // BUG FIX: TextEditingController for the content tab
  late final TextEditingController contentTextController =
      TextEditingController(text: initialRecord.data);

  // Email specific controllers
  final TextEditingController emailToController = TextEditingController();
  final TextEditingController emailSubController = TextEditingController();
  final TextEditingController emailBodyController = TextEditingController();

  // Wi-Fi specific controllers
  final TextEditingController wifiSsidController = TextEditingController();
  final TextEditingController wifiPassController = TextEditingController();
  var wifiEnc = 'WPA/WPA2'.obs;

  // Phone specific controllers
  final TextEditingController phoneController = TextEditingController();

  // Map specific controllers
  final TextEditingController mapLatController = TextEditingController();
  final TextEditingController mapLngController = TextEditingController();
  final TextEditingController mapLinkController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    data.value = initialRecord.data;
    _parseInitialData();
  }

  void _parseInitialData() {
    final format = initialRecord.format;
    final str = initialRecord.data;

    if (format.contains('Email')) {
      if (str.startsWith('MATMSG:')) {
        final parts = str.substring(7).split(';');
        for (var p in parts) {
          if (p.startsWith('TO:')) emailToController.text = p.substring(3);
          if (p.startsWith('SUB:')) emailSubController.text = p.substring(4);
          if (p.startsWith('BODY:')) emailBodyController.text = p.substring(5);
        }
      } else {
        emailToController.text = str;
      }
    } else if (format.contains('Wi-Fi') || format.contains('WIFI')) {
      if (str.startsWith('WIFI:')) {
        final parts = str.substring(5).split(';');
        for (var p in parts) {
          if (p.startsWith('S:')) wifiSsidController.text = p.substring(2);
          if (p.startsWith('T:')) {
            final enc = p.substring(2);
            wifiEnc.value = enc == 'nopass' ? 'None' : (enc == 'WEP' ? 'WEP' : 'WPA/WPA2');
          }
          if (p.startsWith('P:')) wifiPassController.text = p.substring(2);
        }
      } else {
        wifiSsidController.text = str;
      }
    } else if (format.contains('Number') || format.contains('Phone')) {
      if (str.startsWith('tel:')) {
        phoneController.text = str.substring(4);
      } else {
        phoneController.text = str;
      }
    } else if (format.contains('Map') || format.contains('Location')) {
      if (str.startsWith('geo:')) {
        final parts = str.substring(4).split(',');
        if (parts.length >= 2) {
          mapLatController.text = parts[0];
          mapLngController.text = parts[1];
        } else {
          mapLinkController.text = str;
        }
      } else {
        mapLinkController.text = str;
      }
    }
  }

  void updateEmailData() {
    final to = emailToController.text.trim();
    final sub = emailSubController.text.trim();
    final body = emailBodyController.text.trim();
    updateData('MATMSG:TO:$to;SUB:$sub;BODY:$body;;');
  }

  void updateWifiData() {
    final s = wifiSsidController.text.trim();
    final p = wifiPassController.text.trim();
    final enc = wifiEnc.value == 'WPA/WPA2' ? 'WPA' : (wifiEnc.value == 'None' ? 'nopass' : wifiEnc.value);
    updateData('WIFI:S:$s;T:$enc;P:$p;;');
  }

  void updatePhoneData() {
    updateData('tel:${phoneController.text.trim()}');
  }

  void updateMapData() {
    if (mapLatController.text.isNotEmpty && mapLngController.text.isNotEmpty) {
      updateData('geo:${mapLatController.text.trim()},${mapLngController.text.trim()}');
    } else {
      updateData(mapLinkController.text.trim());
    }
  }

  @override
  void onClose() {
    contentTextController.dispose();
    emailToController.dispose();
    emailSubController.dispose();
    emailBodyController.dispose();
    wifiSsidController.dispose();
    wifiPassController.dispose();
    phoneController.dispose();
    mapLatController.dispose();
    mapLngController.dispose();
    mapLinkController.dispose();
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
          _requestReview();
        } else {
          Get.snackbar('Error', 'Failed to save QR code.', snackPosition: SnackPosition.TOP);
        }
      }
    });
  }

  Future<void> _requestReview() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    } catch (e) {
      debugPrint("InAppReview error: $e");
    }
  }

  Future<void> shareQrCode() async {
    AdService.showInterstitialAd(onAdDismissed: () async {
      final bytes = await _captureQrImage();
      if (bytes != null) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/shared_qr.png');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Here is my customized QR Code!');
        _requestReview();
      }
    });
  }
}
