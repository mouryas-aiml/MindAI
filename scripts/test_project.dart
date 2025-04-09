import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  print('Running MindAI tests...');

  // Run Flutter tests
  print('\nRunning Flutter tests...');
  final testResult = await Process.run('flutter', ['test']);

  if (testResult.exitCode != 0) {
    print('\nError: Tests failed');
    print(testResult.stderr);
    exit(1);
  }

  // Run Flutter analyze
  print('\nRunning Flutter analyze...');
  final analyzeResult = await Process.run('flutter', ['analyze']);

  if (analyzeResult.exitCode != 0) {
    print('\nError: Analysis failed');
    print(analyzeResult.stderr);
    exit(1);
  }

  // Check for missing assets
  print('\nChecking assets...');
  final assetsDir = Directory(path.join(Directory.current.path, 'assets'));
  if (!assetsDir.existsSync()) {
    print('Error: assets directory not found');
    exit(1);
  }

  final requiredAssets = [
    'app_logo.png',
    'google_logo.png',
    'facebook_logo.png',
  ];

  for (final asset in requiredAssets) {
    final assetFile = File(path.join(assetsDir.path, asset));
    if (!assetFile.existsSync()) {
      print('Error: Missing required asset: $asset');
      exit(1);
    }
  }

  // Check for missing environment variables
  print('\nChecking environment variables...');
  final envFile = File(path.join(Directory.current.path, '.env'));
  if (!envFile.existsSync()) {
    print('Error: .env file not found');
    exit(1);
  }

  final requiredEnvVars = [
    'AZURE_FACE_API_KEY',
    'AZURE_FACE_ENDPOINT',
    'OPENAI_API_KEY',
    'OPENAI_API_ENDPOINT',
    'FIREBASE_API_KEY',
    'FIREBASE_APP_ID',
    'FIREBASE_MESSAGING_SENDER_ID',
    'FIREBASE_PROJECT_ID',
  ];

  final envContent = await envFile.readAsString();
  for (final envVar in requiredEnvVars) {
    if (!envContent.contains(envVar)) {
      print('Error: Missing required environment variable: $envVar');
      exit(1);
    }
  }

  // Check for missing Firebase configuration
  print('\nChecking Firebase configuration...');
  final firebaseOptionsFile = File(path.join(Directory.current.path, 'lib', 'firebase_options.dart'));
  if (!firebaseOptionsFile.existsSync()) {
    print('Error: firebase_options.dart not found');
    exit(1);
  }

  // Check for missing dependencies
  print('\nChecking dependencies...');
  final pubspecFile = File(path.join(Directory.current.path, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  final requiredDependencies = [
    'flutter',
    'firebase_core',
    'firebase_auth',
    'cloud_firestore',
    'google_sign_in',
    'flutter_facebook_auth',
    'provider',
    'http',
    'image_picker',
    'path',
    'fl_chart',
    'shared_preferences',
    'intl',
    'permission_handler',
    'camera',
    'record',
    'audio_session',
    'flutter_secure_storage',
    'crypto',
    'uuid',
  ];

  final pubspecContent = await pubspecFile.readAsString();
  for (final dependency in requiredDependencies) {
    if (!pubspecContent.contains(dependency)) {
      print('Error: Missing required dependency: $dependency');
      exit(1);
    }
  }

  print('\nAll tests passed successfully!');
  print('\nNext steps:');
  print('1. Run: flutter pub get');
  print('2. Run: flutter pub run build_runner build');
  print('3. Run: flutter run');
} 