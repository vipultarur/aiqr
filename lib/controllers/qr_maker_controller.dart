import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/qr_code_model.dart';
import '../controllers/history_controller.dart';
import 'package:uuid/uuid.dart';
import '../screens/qr_customization_screen.dart';

class QrMakerController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final HistoryController _historyController = Get.find();
  final _uuid = const Uuid();

  // Email specific controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  // WiFi specific controllers
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  var wifiEncryption = 'WPA/WPA2'.obs;

  // Number specific controllers
  final TextEditingController countryCodeController = TextEditingController(text: '+');
  final TextEditingController numberController = TextEditingController();

  // Map specific controllers
  final TextEditingController mapLinkController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();

  var selectedType = 'URL'.obs;
  var isGenerating = false.obs;

  @override
  void onClose() {
    textController.dispose();
    titleController.dispose();
    emailController.dispose();
    subjectController.dispose();
    bodyController.dispose();
    ssidController.dispose();
    passwordController.dispose();
    countryCodeController.dispose();
    numberController.dispose();
    mapLinkController.dispose();
    latController.dispose();
    lngController.dispose();
    super.onClose();
  }

  void setType(String type) {
    selectedType.value = type;
  }

  Future<void> generateQrCode() async {
    String data = '';

    if (selectedType.value == 'Email') {
      final email = emailController.text.trim();
      final subject = subjectController.text.trim();
      final body = bodyController.text.trim();
      if (email.isEmpty) {
        _showError('Please enter an email address.');
        return;
      }
      data = 'MATMSG:TO:$email;SUB:$subject;BODY:$body;;';
    } else if (selectedType.value == 'Wi-Fi') {
      final ssid = ssidController.text.trim();
      final password = passwordController.text.trim();
      final enc = wifiEncryption.value == 'WPA/WPA2' ? 'WPA' : (wifiEncryption.value == 'None' ? 'nopass' : wifiEncryption.value);
      if (ssid.isEmpty) {
        _showError('Please enter the WiFi SSID.');
        return;
      }
      data = 'WIFI:S:$ssid;T:$enc;P:$password;;';
    } else if (selectedType.value == 'Number') {
      final code = countryCodeController.text.trim();
      final number = numberController.text.trim();
      if (number.isEmpty) {
        _showError('Please enter a phone number.');
        return;
      }
      data = 'tel:$code$number';
    } else if (selectedType.value == 'Map') {
      final link = mapLinkController.text.trim();
      final lat = latController.text.trim();
      final lng = lngController.text.trim();
      if (link.isNotEmpty) {
        data = link;
      } else if (lat.isNotEmpty && lng.isNotEmpty) {
        data = 'geo:$lat,$lng';
      } else {
        _showError('Please enter a Google Map link or Latitude/Longitude.');
        return;
      }
    } else {
      data = textController.text.trim();
      if (data.isEmpty) {
        _showError('Please enter some data to generate a QR code.');
        return;
      }
      if (selectedType.value == 'URL' && !data.startsWith('http')) {
        data = 'https://$data';
      }
    }

    isGenerating.value = true;

    final record = QrCodeRecord(
      id: _uuid.v4(),
      title: titleController.text.trim().isNotEmpty
          ? titleController.text.trim()
          : null,
      data: data,
      type: 'generate',
      format: selectedType.value,
      timestamp: DateTime.now(),
    );

    final savedRecord = await _historyController.addRecord(record);
    isGenerating.value = false;

    // Show the customization screen with the generated code
    await Get.to(() => QrCustomizationScreen(record: savedRecord));

    _clearFields();
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      icon: const Icon(Icons.error_outline_rounded),
    );
  }

  void _clearFields() {
    textController.clear();
    titleController.clear();
    emailController.clear();
    subjectController.clear();
    bodyController.clear();
    ssidController.clear();
    passwordController.clear();
    countryCodeController.text = '+';
    numberController.clear();
    mapLinkController.clear();
    latController.clear();
    lngController.clear();
  }
}
