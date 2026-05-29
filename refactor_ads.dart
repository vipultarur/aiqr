import 'dart:io';

void main() async {
  final Map<String, String> moveMapping = {
    'lib/core/constants/ad_constants.dart': 'lib/core/ads/ad_constants.dart',
    'lib/services/ad_service.dart': 'lib/core/ads/ad_service.dart',
    'lib/core/services/ad_service.dart': 'lib/core/ads/ad_service.dart',
    'lib/core/widgets/banner_ad_widget.dart': 'lib/core/ads/banner_ad_widget.dart',
    'lib/core/widgets/native_ad_widget.dart': 'lib/core/ads/native_ad_widget.dart',
  };

  print('Starting ad refactor process...');

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
      print('Moved: $sourcePath -> $destPath');
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
          final oldImportPath = 'package:aiqr_app/${entry.key.substring(4)}'; // remove 'lib/'
          final newImportPath = 'package:aiqr_app/${entry.value.substring(4)}'; // remove 'lib/'

          if (content.contains(oldImportPath)) {
            content = content.replaceAll(oldImportPath, newImportPath);
            changed = true;
          }
        }

        if (changed) {
          await entity.writeAsString(content);
          print('Updated imports in: ${entity.path}');
        }
      }
    }
  }

  print('Ad Refactoring complete!');
}
