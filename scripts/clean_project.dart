import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  print('Cleaning MindAI project...');

  // Clean Flutter build
  print('\nCleaning Flutter build...');
  await Process.run('flutter', ['clean']);

  // Clean pub cache
  print('\nCleaning pub cache...');
  await Process.run('flutter', ['pub', 'cache', 'clean']);

  // Remove build directories
  final buildDirs = [
    'build',
    '.dart_tool',
    '.flutter-plugins',
    '.flutter-plugins-dependencies',
    '.packages',
    '.pub-cache',
    '.pub',
  ];

  for (final dir in buildDirs) {
    final directory = Directory(path.join(Directory.current.path, dir));
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
      print('Removed directory: $dir');
    }
  }

  // Remove generated files
  final generatedFiles = [
    '*.g.dart',
    '*.freezed.dart',
    '*.mocks.dart',
  ];

  for (final pattern in generatedFiles) {
    final files = Directory(path.join(Directory.current.path, 'lib'))
        .listSync(recursive: true)
        .where((entity) => entity is File && path.basename(entity.path).contains(pattern))
        .cast<File>();

    for (final file in files) {
      await file.delete();
      print('Removed file: ${path.relative(file.path)}');
    }
  }

  // Remove temporary files
  final tempFiles = [
    '*.tmp',
    '*.temp',
    '*.swp',
    '*~',
  ];

  for (final pattern in tempFiles) {
    final files = Directory(Directory.current.path)
        .listSync(recursive: true)
        .where((entity) => entity is File && path.basename(entity.path).contains(pattern))
        .cast<File>();

    for (final file in files) {
      await file.delete();
      print('Removed file: ${path.relative(file.path)}');
    }
  }

  print('\nProject cleaned successfully!');
  print('\nNext steps:');
  print('1. Run: flutter pub get');
  print('2. Run: flutter pub run build_runner build');
  print('3. Run: flutter run');
} 