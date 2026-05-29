import 'dart:io';

void main() async {
  final Map<String, String> moveMapping = {
    'lib/controllers/qr_scanner_controller.dart': 'lib/features/scanner/controllers/qr_scanner_controller.dart',
    'lib/screens/qr_scanner_screen.dart': 'lib/features/scanner/screens/qr_scanner_screen.dart',
    'lib/screens/gallery_scan_screen.dart': 'lib/features/scanner/screens/gallery_scan_screen.dart',
    'lib/widgets/scan_frame.dart': 'lib/features/scanner/widgets/scan_frame.dart',
    'lib/widgets/glitter_overlay.dart': 'lib/features/scanner/widgets/glitter_overlay.dart',
    'lib/widgets/scan_result_bottom_sheet.dart': 'lib/features/scanner/widgets/scan_result_bottom_sheet.dart',
    
    'lib/controllers/qr_maker_controller.dart': 'lib/features/generator/controllers/qr_maker_controller.dart',
    'lib/controllers/qr_customization_controller.dart': 'lib/features/generator/controllers/qr_customization_controller.dart',
    'lib/screens/all_qr_types_screen.dart': 'lib/features/generator/screens/all_qr_types_screen.dart',
    'lib/screens/binary_qr_creator_screen.dart': 'lib/features/generator/screens/binary_qr_creator_screen.dart',
    'lib/screens/string_qr_creator_screen.dart': 'lib/features/generator/screens/string_qr_creator_screen.dart',
    'lib/screens/qr_customization_screen.dart': 'lib/features/generator/screens/qr_customization_screen.dart',

    'lib/controllers/history_controller.dart': 'lib/features/history/controllers/history_controller.dart',
    'lib/services/history_service.dart': 'lib/features/history/services/history_service.dart',
    'lib/screens/qr_maker_history_screen.dart': 'lib/features/history/screens/qr_maker_history_screen.dart',
    'lib/screens/scan_saved_history_screen.dart': 'lib/features/history/screens/scan_saved_history_screen.dart',
    'lib/screens/qr_display.dart': 'lib/features/history/screens/qr_display.dart',
    'lib/widgets/history_item.dart': 'lib/features/history/widgets/history_item.dart',
    'lib/widgets/details_bottom_sheet.dart': 'lib/features/history/widgets/details_bottom_sheet.dart',
    'lib/widgets/rename_bottom_sheet.dart': 'lib/features/history/widgets/rename_bottom_sheet.dart',

    'lib/controllers/settings_controller.dart': 'lib/features/settings/controllers/settings_controller.dart',
    'lib/services/settings_service.dart': 'lib/features/settings/services/settings_service.dart',
    'lib/screens/settings_screen.dart': 'lib/features/settings/screens/settings_screen.dart',

    'lib/controllers/bottom_nav_controller.dart': 'lib/features/main/controllers/bottom_nav_controller.dart',
    'lib/screens/main_screen.dart': 'lib/features/main/screens/main_screen.dart',
    'lib/screens/splash_screen.dart': 'lib/features/main/screens/splash_screen.dart',
    'lib/widgets/bottom_nav_bar.dart': 'lib/features/main/widgets/bottom_nav_bar.dart',

    'lib/theme/app_colors.dart': 'lib/core/theme/app_colors.dart',
    'lib/theme/app_theme.dart': 'lib/core/theme/app_theme.dart',
    'lib/theme/app_dimensions.dart': 'lib/core/theme/app_dimensions.dart',
    'lib/theme/app_text_styles.dart': 'lib/core/theme/app_text_styles.dart',
    
    'lib/utils/app_logger.dart': 'lib/core/utils/app_logger.dart',
    'lib/utils/image_utils.dart': 'lib/core/utils/image_utils.dart',
    
    'lib/widgets/gradient_button.dart': 'lib/core/widgets/gradient_button.dart',
    'lib/widgets/base_bottom_sheets.dart': 'lib/core/widgets/base_bottom_sheets.dart',
    'lib/widgets/native_ad_widget.dart': 'lib/core/widgets/native_ad_widget.dart',
    'lib/widgets/banner_ad_widget.dart': 'lib/core/widgets/banner_ad_widget.dart',
    'lib/elements/build_base_bottom_sheet.dart': 'lib/core/widgets/build_base_bottom_sheet.dart',
    'lib/elements/build_bottom_button.dart': 'lib/core/widgets/build_bottom_button.dart',
    'lib/elements/build_divider.dart': 'lib/core/widgets/build_divider.dart',
    'lib/elements/build_navigation_row.dart': 'lib/core/widgets/build_navigation_row.dart',
    'lib/elements/build_section_container.dart': 'lib/core/widgets/build_section_container.dart',
    'lib/elements/build_section_header.dart': 'lib/core/widgets/build_section_header.dart',
    'lib/widgets/confirmation_bottom_sheet.dart': 'lib/core/widgets/confirmation_bottom_sheet.dart',
  };

  print('Starting refactor process...');

  // 1. Move files
  for (var entry in moveMapping.entries) {
    final sourcePath = entry.key;
    final destPath = entry.value;

    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      final destFile = File(destPath);
      if (!await destFile.parent.exists()) {
        await destFile.parent.create(recursive: true);
      }
      await sourceFile.rename(destPath);
      print('Moved: \$sourcePath -> \$destPath');
    }
  }

  // 2. Update imports in all dart files
  final libDir = Directory('lib');
  if (await libDir.exists()) {
    await for (var entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        String content = await entity.readAsString();
        bool changed = false;

        for (var entry in moveMapping.entries) {
          const oldImportPath = 'package:aiqr_app/\${entry.key.substring(4)}'; // remove 'lib/'
          const newImportPath = 'package:aiqr_app/\${entry.value.substring(4)}'; // remove 'lib/'

          if (content.contains(oldImportPath)) {
            content = content.replaceAll(oldImportPath, newImportPath);
            changed = true;
          }
        }

        if (changed) {
          await entity.writeAsString(content);
          print('Updated imports in: \${entity.path}');
        }
      }
    }
  }

  print('Refactoring complete!');
}
