import 'dart:io';

void main() {
  final dir = Directory('.');
  final files = _getAllFiles(dir);

  final replacements = {
    // Types
    'GetWidgetBuilder': 'RxWidgetBuilder',
    'GetCondition': 'RxCondition',
    'GetListener<': 'RxWidgetListener<',
    'GetListener(': 'RxWidgetListener(',
    'GetListenerWidget': 'RxListener',

    // Widgets
    'GetChanger': 'RxBuilder',
    'GetConsumer': 'RxConsumer',
    'GetSelector': 'RxSelector',
    'GetMultiChanger': 'RxMultiBuilder',

    // Generic names in docs/strings
    'get_changer': 'rx_builder',
    'get_consumer': 'rx_consumer',
    'get_listener': 'rx_listener',
    'get_selector': 'rx_selector',
    'get_multi_changer': 'rx_multi_builder',
  };

  for (final file in files) {
    if (!file.path.endsWith('.dart') && !file.path.endsWith('.md')) continue;

    String content = file.readAsStringSync();
    bool changed = false;

    for (final entry in replacements.entries) {
      if (content.contains(entry.key)) {
        content = content.replaceAll(entry.key, entry.value);
        changed = true;
      }
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated content in: ${file.path}');
    }
  }

  // Rename test files
  final testDir = Directory('test');
  if (testDir.existsSync()) {
    for (final entity in testDir.listSync()) {
      if (entity is File) {
        final name = entity.path.split('/').last;
        if (name.contains('get_')) {
          final newName = name
              .replaceAll('get_changer', 'rx_builder')
              .replaceAll('get_consumer', 'rx_consumer')
              .replaceAll('get_listener', 'rx_listener')
              .replaceAll('get_selector', 'rx_selector')
              .replaceAll('get_multi_changer', 'rx_multi_builder');

          if (newName != name) {
            final newPath = entity.path.replaceAll(name, newName);
            entity.renameSync(newPath);
            print('Renamed file: ${entity.path} -> $newPath');
          }
        }
      }
    }
  }
}

List<File> _getAllFiles(Directory dir) {
  List<File> files = [];
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File &&
        !entity.path.contains('.git') &&
        !entity.path.contains('.dart_tool') &&
        !entity.path.contains('build/') &&
        !entity.path.endsWith('rename_script.dart')) {
      files.add(entity);
    }
  }
  return files;
}
