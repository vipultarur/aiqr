import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/features/history/controllers/history_controller.dart';
import 'package:aiqr_app/core/utils/app_logger.dart';
import 'package:uuid/uuid.dart';
import 'package:aiqr_app/features/generator/screens/qr_customization_screen.dart';
import 'package:aiqr_app/models/qr_code_model.dart';

/// Controls QR code creation flow for string-based and binary QR types.
///
/// Holds all [TextEditingController] and [FocusNode] instances used across
/// the creator screens. Disposed via [onClose].
class QrMakerController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();

  // ── Email fields ─────────────────────────────────────────────────────────────
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  // ── Wi-Fi fields ─────────────────────────────────────────────────────────────
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// PRESERVED: observable so the dropdown in StringQrCreatorScreen reacts.
  var wifiEncryption = 'WPA/WPA2'.obs;

  // ── Phone number fields ───────────────────────────────────────────────────────
  final TextEditingController countryCodeController =
      TextEditingController(text: '+');
  final TextEditingController numberController = TextEditingController();

  // ── Map fields ───────────────────────────────────────────────────────────────
  final TextEditingController mapLinkController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();

  // ── Observable state ─────────────────────────────────────────────────────────
  var selectedType = 'URL'.obs;
  var isGenerating = false.obs;

  final HistoryController _historyController = Get.find();
  final _uuid = const Uuid();

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    // BUG FIX: focusNode1 and focusNode2 were missing from the original dispose
    // list, causing a memory leak on every app session.
    focusNode1.dispose();
    focusNode2.dispose();

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

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Sets the active QR type; drives which input fields are shown.
  void setType(String type) => selectedType.value = type;

  /// Builds the QR data string, saves a history record, and opens the
  /// customisation screen.
  Future<void> generateQrCode() async {
    final data = _buildDataString();
    if (data == null) return; // validation failed, error already shown

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

    try {
      final savedRecord = await _historyController.addRecord(record);
      isGenerating.value = false;
      await Get.to<void>(() => QrCustomizationScreen(record: savedRecord));
    } catch (e, st) {
      AppLogger.error('generateQrCode failed', e, st);
      isGenerating.value = false;
      _showError('Something went wrong. Please try again.');
    }

    _clearFields();
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  /// Returns the formatted QR data string, or [null] if validation fails.
  String? _buildDataString() {
    switch (selectedType.value) {
      case 'Email':
        return _buildEmailData();
      case 'Wi-Fi':
        return _buildWifiData();
      case 'Number':
        return _buildPhoneData();
      case 'Map':
        return _buildMapData();
      default:
        return _buildGenericData();
    }
  }

  String? _buildEmailData() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter an email address.');
      return null;
    }
    // PRESERVED: MATMSG format — standardised mailto QR encoding
    return 'MATMSG:TO:$email;'
        'SUB:${subjectController.text.trim()};'
        'BODY:${bodyController.text.trim()};;';
  }

  String? _buildWifiData() {
    final ssid = ssidController.text.trim();
    if (ssid.isEmpty) {
      _showError('Please enter the WiFi network name (SSID).');
      return null;
    }
    // PRESERVED: WIFI: format — standardised Wi-Fi QR encoding
    final enc = wifiEncryption.value == 'WPA/WPA2'
        ? 'WPA'
        : (wifiEncryption.value == 'None' ? 'nopass' : wifiEncryption.value);
    return 'WIFI:S:$ssid;T:$enc;P:${passwordController.text.trim()};;';
  }

  String? _buildPhoneData() {
    final number = numberController.text.trim();
    if (number.isEmpty) {
      _showError('Please enter a phone number.');
      return null;
    }
    // PRESERVED: tel: URI scheme
    return 'tel:${countryCodeController.text.trim()}$number';
  }

  String? _buildMapData() {
    final link = mapLinkController.text.trim();
    final lat = latController.text.trim();
    final lng = lngController.text.trim();

    if (link.isNotEmpty) return link;
    if (lat.isNotEmpty && lng.isNotEmpty) {
      // PRESERVED: geo: URI scheme
      return 'geo:$lat,$lng';
    }
    _showError('Please enter a Google Maps link or Latitude/Longitude.');
    return null;
  }

  String? _buildGenericData() {
    var data = textController.text.trim();
    if (data.isEmpty) {
      _showError('Please enter some data to generate a QR code.');
      return null;
    }
    if (selectedType.value == 'URL' && !data.startsWith('http')) {
      data = 'https://$data';
    }
    return data;
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
