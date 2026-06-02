import 'package:flutter/material.dart';

class AnimatedScannerFrame extends StatefulWidget {
  final double width;
  final double height;
  final double cornerLength;
  final double cornerWidth;
  final bool isScanning;

  const AnimatedScannerFrame({
    super.key,
    this.width = 250,
    this.height = 250,
    this.cornerLength = 40,
    this.cornerWidth = 5,
    this.isScanning = true,
  });

  @override
  State<AnimatedScannerFrame> createState() => _AnimatedScannerFrameState();
}

class _AnimatedScannerFrameState extends State<AnimatedScannerFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.isScanning) {
      _animationController.repeat(reverse: true);
    }

    const double margin = 16;
    const double lineHeight = 4.0;

    _positionAnimation =
        Tween<double>(
          begin: margin,
          end: widget.height - margin - lineHeight,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutSine,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedScannerFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using Theme primary color for a vibrant, stylish look
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          // Background soft glow
          Center(
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          
          // Corner accents
          _buildCorner(Alignment.topLeft, primaryColor),
          _buildCorner(Alignment.topRight, primaryColor),
          _buildCorner(Alignment.bottomLeft, primaryColor),
          _buildCorner(Alignment.bottomRight, primaryColor),

          // Animated scanning line
          if (widget.isScanning)
            AnimatedBuilder(
              animation: _positionAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _positionAnimation.value,
                  left: 8,
                  right: 8,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.0),
                          primaryColor,
                          primaryColor,
                          primaryColor.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.8),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        width: widget.cornerLength,
        height: widget.cornerLength,
        decoration: BoxDecoration(
          border: _getBorder(alignment, color),
          borderRadius: _getBorderRadius(alignment),
        ),
      ),
    );
  }

  Border _getBorder(Alignment alignment, Color color) {
    BorderSide b = BorderSide(color: color, width: widget.cornerWidth);
    if (alignment == Alignment.topLeft) return Border(top: b, left: b);
    if (alignment == Alignment.topRight) return Border(top: b, right: b);
    if (alignment == Alignment.bottomLeft) {
      return Border(bottom: b, left: b);
    }
    return Border(bottom: b, right: b); 
  }

  BorderRadius _getBorderRadius(Alignment alignment) {
    const r = Radius.circular(32);
    if (alignment == Alignment.topLeft) {
      return const BorderRadius.only(topLeft: r);
    }
    if (alignment == Alignment.topRight) {
      return const BorderRadius.only(topRight: r);
    }
    if (alignment == Alignment.bottomLeft) {
      return const BorderRadius.only(bottomLeft: r);
    }
    return const BorderRadius.only(bottomRight: r);
  }
}
