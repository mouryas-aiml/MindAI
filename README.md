# MindAI

An AI-powered mental health support application that helps users track their emotions, analyze their mood patterns, and receive personalized support.

## Features

- AI-powered therapy chatbot
- Facial emotion recognition
- Voice emotion analysis
- Mood tracking and analytics
- Secure authentication
- Privacy-focused design
- Cross-platform support

## Prerequisites

- Flutter SDK (>=3.2.0)
- Dart SDK (>=3.2.0)
- Firebase account and project
- Azure Face API account
- OpenAI API account

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/mindai.git
   cd mindai
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up the project:
   ```bash
   dart run scripts/setup_project.dart
   ```

4. Update configuration files:
   - Update `.env` with your API keys and configuration
   - Update `lib/firebase_options.dart` with your Firebase configuration
   - Add your app logo and social media logos to the `assets` directory

## Running the App

1. Connect a device or start an emulator

2. Run the app:
   ```bash
   dart run scripts/run_app.dart
   ```

Or simply:
```bash
flutter run
```

## Project Structure

```
lib/
├── config/
│   └── app_config.dart
├── core/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── emotion_model.dart
│   └── services/
│       ├── auth_service.dart
│       └── emotion_service.dart
├── features/
│   ├── auth/
│   │   └── screens/
│   │       └── signup_screen.dart
│   ├── profile/
│   │   └── screens/
│   │       └── profile_screen.dart
│   └── reports/
│       └── screens/
│           └── reports_screen.dart
└── main.dart
```

## Configuration

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```
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
```

### Firebase Configuration

1. Create a new Firebase project
2. Add your apps (Android, iOS, Web)
3. Download the configuration files
4. Update `lib/firebase_options.dart` with your Firebase configuration

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- OpenAI for GPT-4 and Whisper APIs
- Azure for Face API
- Firebase for authentication and backend services
- Flutter team for the amazing framework

## Support

For support, email support@mindai.app or join our Slack channel.
