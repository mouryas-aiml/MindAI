import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  print('Setting up MindAI project...');

  // Create necessary directories
  final directories = [
    'lib/core/models',
    'lib/core/services',
    'lib/features/auth/screens',
    'lib/features/profile/screens',
    'lib/features/reports/screens',
    'assets',
    'scripts',
  ];

  for (final dir in directories) {
    final directory = Directory(path.join(Directory.current.path, dir));
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('Created directory: $dir');
    }
  }

  // Run setup scripts
  print('\nSetting up environment variables...');
  await Process.run('dart', ['run', 'scripts/setup_env.dart']);

  print('\nSetting up Firebase configuration...');
  await Process.run('dart', ['run', 'scripts/setup_firebase.dart']);

  print('\nInstalling dependencies...');
  await Process.run('flutter', ['pub', 'get']);

  print('\nProject setup complete!');
  print('\nNext steps:');
  print('1. Update the values in the .env file with your actual API keys and configuration');
  print('2. Update the values in lib/firebase_options.dart with your actual Firebase configuration');
  print('3. Add your app logo and social media logos to the assets directory');
  print('4. Run the app using: flutter run');
} 