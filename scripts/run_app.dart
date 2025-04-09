import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  print('Running MindAI app...');

  // Check if Flutter is installed
  try {
    await Process.run('flutter', ['--version']);
  } catch (e) {
    print('Error: Flutter is not installed or not in PATH');
    print('Please install Flutter and add it to your PATH');
    exit(1);
  }

  // Check if .env file exists
  final envFile = File(path.join(Directory.current.path, '.env'));
  if (!envFile.existsSync()) {
    print('Error: .env file not found');
    print('Please run: dart run scripts/setup_project.dart first');
    exit(1);
  }

  // Check if firebase_options.dart exists
  final firebaseOptionsFile = File(path.join(Directory.current.path, 'lib', 'firebase_options.dart'));
  if (!firebaseOptionsFile.existsSync()) {
    print('Error: firebase_options.dart not found');
    print('Please run: dart run scripts/setup_project.dart first');
    exit(1);
  }

  // Check if assets exist
  final assetsDir = Directory(path.join(Directory.current.path, 'assets'));
  if (!assetsDir.existsSync()) {
    print('Error: assets directory not found');
    print('Please run: dart run scripts/setup_project.dart first');
    exit(1);
  }

  // Get available devices
  final devicesResult = await Process.run('flutter', ['devices']);
  final devices = devicesResult.stdout.toString().split('\n')
      .where((line) => line.contains('•'))
      .map((line) => line.split('•')[1].trim())
      .toList();

  if (devices.isEmpty) {
    print('Error: No devices found');
    print('Please connect a device or start an emulator');
    exit(1);
  }

  // If only one device is available, use it
  if (devices.length == 1) {
    print('Running on ${devices[0]}...');
    await Process.run('flutter', ['run', '-d', devices[0]]);
  } else {
    // If multiple devices are available, let the user choose
    print('\nAvailable devices:');
    for (var i = 0; i < devices.length; i++) {
      print('${i + 1}. ${devices[i]}');
    }

    print('\nEnter the number of the device to run on:');
    final input = stdin.readLineSync();
    final index = int.tryParse(input ?? '') ?? 0;

    if (index < 1 || index > devices.length) {
      print('Error: Invalid device number');
      exit(1);
    }

    print('\nRunning on ${devices[index - 1]}...');
    await Process.run('flutter', ['run', '-d', devices[index - 1]]);
  }
} 