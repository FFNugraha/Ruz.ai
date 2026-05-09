# Ruz.ai

An AI-powered assistant application built with Flutter, integrating Google Generative AI (Gemini), speech recognition, text-to-speech, and Firebase backend services.

## Features

- **Generative AI Chat**: Powered by Google's Gemini AI for smart, conversational responses.
- **Voice Interaction**: Includes Speech-to-Text for voice inputs and Text-to-Speech to read out responses.
- **Cloud Backend**: Uses Firebase for Authentication, Firestore database, and Cloud Storage.
- **Media Support**: Image picking and camera integration for visual inputs to the AI.
- **Local Storage**: Caching and local preferences support via `shared_preferences` and `sqflite`.

## Getting Started

To run this project locally, follow these steps:

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version ^3.10.7)
- Android Studio / Xcode for emulators or physical device testing
- Firebase project setup
- Google Gemini API Key

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd ruz.ai
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Environment Setup:**
   Create a `.env` file in the root directory of the project and add your API keys:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
   *Note: Never commit your `.env` file to version control.*

4. **Firebase Configuration:**
   Ensure you have the `firebase_options.dart` generated via FlutterFire CLI in the `lib/` directory or follow the standard Firebase initialization for Flutter.

### Running the App

To run the application on an emulator or a connected device:
```bash
flutter run
```

## Guide to Testing the App

### 1. Manual App Testing
- **Chat Interface**: Open the app and start typing messages. Ensure the Gemini AI responds accurately.
- **Voice Input/Output**: Tap the microphone icon to test Speech-to-Text. Listen to the AI's response to test Text-to-Speech.
- **Image Input**: Test the camera and gallery features to upload images along with your prompts.

### 2. Automated Testing
The project includes a testing suite. To run the automated tests:

Run all tests:
```bash
flutter test
```

### 3. Linting and Code Analysis
To ensure code quality and adherence to Flutter best practices:
```bash
flutter analyze
```

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Google Generative AI SDK for Dart](https://pub.dev/packages/google_generative_ai)
- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
