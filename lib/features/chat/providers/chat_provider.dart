import 'package:flutter/foundation.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../profile/models/field_profile_model.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.type = MessageType.text,
  });
}

enum MessageType { text, image, system }

class ChatProvider extends ChangeNotifier {
  final GeminiService _gemini;
  final SpeechService _speech;
  // ignore: unused_field
  final FirebaseService _firebase;
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _autoSpeak = true;
  FieldProfile? _currentField;

  ChatProvider({
    required GeminiService gemini,
    required SpeechService speech,
    required FirebaseService firebase,
  }) : _gemini = gemini, _speech = speech, _firebase = firebase {
    _initWelcomeMessage();
  }

  void _initWelcomeMessage() {
    _messages = [
      ChatMessage(
        id: 'welcome',
        text: 'Halo! Saya ruz.ai, asisten pertanian padi kamu 🌾\\n\\nKamu bisa tanya soal hama, pupuk, irigasi, atau kondisi tanaman. Atau gunakan fitur foto daun untuk diagnosis langsung ya!',
        isFromUser: false,
        timestamp: DateTime.now(),
      )
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Tambahkan pesan user
    _addMessage(text, isFromUser: true);
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _gemini.sendChatMessage(
        text,
        fieldProfile: _currentField,
      );
      
      _addMessage(response, isFromUser: false);
      
      if (_autoSpeak) {
        await _speech.speak(response);
      }
    } catch (e) {
      _addMessage('Maaf, terjadi kesalahan koneksi. Coba lagi ya 🙏', isFromUser: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startVoiceInput() async {
    _isListening = true;
    notifyListeners();
    
    await _speech.startListening(
      onResult: (text) => sendMessage(text),
      onListeningComplete: () {
        _isListening = false;
        notifyListeners();
      },
    );
  }

  void _addMessage(String text, {required bool isFromUser}) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isFromUser: isFromUser,
      timestamp: DateTime.now(),
    ));
  }

  void clearChat() {
    _gemini.resetChatSession();
    _messages = [];
    _initWelcomeMessage();
    notifyListeners();
  }

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get autoSpeak => _autoSpeak;
  void toggleAutoSpeak() { _autoSpeak = !_autoSpeak; notifyListeners(); }
  void setFieldProfile(FieldProfile profile) { _currentField = profile; }
}
