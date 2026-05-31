import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/features/scanner/controllers/qr_scanner_controller.dart';
import 'package:aiqr_app/features/scanner/widgets/glitter_overlay.dart';
import 'package:aiqr_app/core/widgets/gradient_button.dart';
import 'package:aiqr_app/core/ads/banner_ad_widget.dart';

class GalleryScanScreen extends StatefulWidget {
  final String imagePath;

  const GalleryScanScreen({super.key, required this.imagePath});

  @override
  State<GalleryScanScreen> createState() => _GalleryScanScreenState();
}

class _GalleryScanScreenState extends State<GalleryScanScreen> {
  bool _isScanning = false;
  final QrScannerController _scannerController =
      Get.find<QrScannerController>();

  Future<void> _performScan() async {
    setState(() {
      _isScanning = true;
    });

    // Artificial delay to show off the beautiful glittering effect as requested
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    try {
      final capture = await _scannerController.mobileController.analyzeImage(
        widget.imagePath,
      );

      if (capture != null && capture.barcodes.isNotEmpty) {
        // Found QR code(s) - Stop animation immediately
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }

        await _scannerController.handleBarcode(capture);
      } else {
        // No QR found - Stop animation
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
        Get.snackbar(
          'No QR Code Found',
          'We couldn\'t find any QR code in this image.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
      Get.snackbar(
        'Error',
        'An error occurred while scanning the image.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The Image (Centered)
          Align(
            alignment: Alignment.center,
            child: GlitterOverlay(
              isAnimating: _isScanning,
              child: Hero(
                tag: widget.imagePath,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),

          // Top Bar (Back Button and Animated Header)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Get.back<void>(),
                    ),
                  ),
                  if (_isScanning)
                    const Text(
                      'Scanning...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GSansFlex',
                      ),
                    )
                  else
                    const SizedBox(width: 48), // Spacer for centering
                  const SizedBox(width: 48), // Balancer for centering
                ],
              ),
            ),
          ),

          // Banner Ad
          const Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: BannerAdWidget(),
          ),

          // Bottom Scan Button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isScanning)
                  GradientButton(
                    onPressed: _performScan,
                    child: const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GSansFlex',
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [
                                  Color(0xFF4285F4), // Blue
                                  Color(0xFFEA4335), // Red
                                  Color(0xFFFBBC05), // Yellow
                                  Color(0xFF34A853), // Green
                                ],
                              ).createShader(bounds);
                            },
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Scanning for QR codes...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GSansFlex',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
