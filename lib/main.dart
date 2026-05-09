import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/gemini_service.dart';
import 'core/services/speech_service.dart';
import 'core/services/firebase_service.dart';
import 'features/chat/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final geminiService = GeminiService();
  final speechService = SpeechService();
  final firebaseService = FirebaseService();

  await speechService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            gemini: geminiService,
            speech: speechService,
            firebase: firebaseService,
          ),
        ),
      ],
      child: const RuzaiApp(),
    ),
  );
}
