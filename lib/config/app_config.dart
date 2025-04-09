class AppConfig {
  // API Keys and Endpoints
  static const String azureFaceApiKey = String.fromEnvironment('AZURE_FACE_API_KEY');
  static const String azureFaceEndpoint = String.fromEnvironment('AZURE_FACE_ENDPOINT');
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String openAiEndpoint = String.fromEnvironment('OPENAI_API_ENDPOINT');

  // Firebase Configuration
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  // App Settings
  static const String appName = 'MindAI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'An AI-powered mental health support application';

  // Feature Flags
  static const bool enableVoiceEmotionAnalysis = true;
  static const bool enableFacialEmotionAnalysis = true;
  static const bool enableMoodTracking = true;
  static const bool enableEmergencyContacts = true;

  // UI Settings
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration emotionAnalysisTimeout = Duration(seconds: 15);

  // Cache Settings
  static const Duration emotionDataCacheDuration = Duration(hours: 24);
  static const Duration userDataCacheDuration = Duration(hours: 1);

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection and try again.';
  static const String authenticationError = 'Authentication failed. Please try again.';
  static const String permissionError = 'Permission denied. Please check your settings.';
  static const String validationError = 'Please check your input and try again.';

  // Success Messages
  static const String loginSuccess = 'Successfully logged in!';
  static const String signupSuccess = 'Account created successfully!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String emotionSavedSuccess = 'Emotion data saved successfully!';

  // Asset Paths
  static const String logoPath = 'assets/app_logo.png';
  static const String googleLogoPath = 'assets/google_logo.png';
  static const String facebookLogoPath = 'assets/facebook_logo.png';

  // Route Names
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String profileRoute = '/profile';
  static const String reportsRoute = '/reports';
  static const String settingsRoute = '/settings';
  static const String emergencyRoute = '/emergency';

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String emotionDataKey = 'emotion_data';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // Analytics Events
  static const String loginEvent = 'login';
  static const String signupEvent = 'signup';
  static const String emotionAnalysisEvent = 'emotion_analysis';
  static const String moodTrackingEvent = 'mood_tracking';
  static const String emergencyContactEvent = 'emergency_contact';
  static const String profileUpdateEvent = 'profile_update';
} 