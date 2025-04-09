import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  final envFile = File(path.join(Directory.current.path, '.env'));
  
  if (!envFile.existsSync()) {
    envFile.createSync();
    envFile.writeAsStringSync('''
# Azure Face API Configuration
AZURE_FACE_API_KEY=your_azure_face_api_key
AZURE_FACE_ENDPOINT=https://your-region.api.cognitive.microsoft.com

# OpenAI API Configuration
OPENAI_API_KEY=your_openai_api_key
OPENAI_API_ENDPOINT=https://api.openai.com

# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_MESSAGING_SENDER_ID=your_firebase_messaging_sender_id
FIREBASE_PROJECT_ID=your_firebase_project_id
''');
    print('Created .env file with template values.');
    print('Please update the values in the .env file with your actual API keys and configuration.');
  } else {
    print('.env file already exists.');
  }
} 