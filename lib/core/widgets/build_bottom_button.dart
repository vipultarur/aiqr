import 'package:flutter/material.dart';
import 'package:aiqr_app/core/widgets/gradient_button.dart';

/// Build a bottom button with icon and label
///
/// [icon] - The icon to display on the button
/// [label] - The label to display on the button
/// [onTap] - The callback to be called when the button is pressed
/// Used in qr_display.dart, scan_result_bottom_sheet.dart
Widget buildBottomButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GradientButton(
    onPressed: onTap,
    height: 56,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
