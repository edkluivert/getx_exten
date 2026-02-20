import 'dart:io';

void main() {
  // Fix lib/src circular imports
  final srcDir = Directory('lib/src');
  for (final entity in srcDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      // Remove the circular import
      content = content.replaceAll(
          "import 'package:getx_exten/getx_exten.dart';",
          "import 'package:get/get.dart';\nimport 'package:flutter/widgets.dart';\nimport 'package:getx_exten/src/types/types.dart';\nimport 'package:getx_exten/src/state/rx_bloc_cubit/rx_cubit.dart';\nimport 'package:getx_exten/src/state/rx_bloc_cubit/rx_bloc.dart';");
      entity.writeAsStringSync(content);
    }
  }

  // Deduplicate imports in test directory
  final testDir = Directory('test');
  final exampleDir = Directory('example/lib');
  final dirs = [testDir, exampleDir];

  for (final dir in dirs) {
    if (dir.existsSync()) {
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          String content = entity.readAsStringSync();
          final lines = content.split('\n');
          final newLines = <String>[];
          final seenImports = <String>{};

          for (final line in lines) {
            if (line.trim().startsWith('import ')) {
              if (!seenImports.contains(line)) {
                seenImports.add(line);
                newLines.add(line);
              }
            } else {
              newLines.add(line);
            }
          }
          entity.writeAsStringSync(newLines.join('\n'));
        }
      }
    }
  }
}
