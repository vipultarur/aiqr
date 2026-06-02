import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aiqr_app/features/scanner/controllers/qr_scanner_controller.dart';
import 'package:aiqr_app/features/scanner/widgets/scan_frame.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate the scanner controller that will be active while this screen is built
    final QrScannerController controller = Get.put(QrScannerController());
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for camera
      body: Stack(
        children: [
          // Camera View
          Positioned.fill(
            child: MobileScanner(
              controller: controller.mobileController,
              onDetect: controller.handleBarcode,
            ),
          ),

          // Dimmed overlay with a clear cutout for the scanner frame
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  painter: ScannerOverlayPainter(
                    scanWindow: Rect.fromCenter(
                      center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
                      width: 260,
                      height: 260,
                    ),
                    borderRadius: 32,
                  ),
                );
              },
            ),
          ),

          // Top Bar (Title and Options)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scanner',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Point at a QR code',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GSansFlex',
                      ),
                    ),
                  ],
                ),
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () => Get.toNamed('/settings'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scanner Frame (Centered)
          Center(
            child: Obx(
              () => AnimatedScannerFrame(
                isScanning: controller.isScanning.value,
                width: 260,
                height: 260,
              ),
            ),
          ),

          // Bottom Action Buttons (Flash and Gallery)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 130,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => _buildActionButton(
                    icon: controller.isTorchOn.value
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    label: 'Flash',
                    onTap: () => controller.toggleTorch(),
                    isActive: controller.isTorchOn.value,
                    activeColor: Colors.amber,
                    activeIconColor: Colors.black87,
                  ),
                ),
                const SizedBox(width: 48),
                _buildActionButton(
                  icon: Icons.image_outlined,
                  label: 'Gallery',
                  onTap: () => controller.scanFromGallery(),
                  isActive: false,
                  activeColor: primaryColor,
                  activeIconColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
    required Color activeColor,
    required Color activeIconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive 
                    ? activeColor.withValues(alpha: 0.5) 
                    : Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 4,
                      )
                    ]
                  : [],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      icon,
                      key: ValueKey(icon),
                      color: isActive ? activeIconColor : Colors.white.withValues(alpha: 0.9),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'GSansFlex',
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;

  ScannerOverlayPainter({required this.scanWindow, this.borderRadius = 32});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          scanWindow,
          Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Use difference operation to create a cutout
    final path = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(path, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow || 
           oldDelegate.borderRadius != borderRadius;
  }
}
