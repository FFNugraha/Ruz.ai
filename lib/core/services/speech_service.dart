import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _sttInitialized = false;

  Future<void> initialize() async {
    _sttInitialized = await _stt.initialize(
      onError: (error) => print('STT Error: $error'),
      debugLogging: false,
    );
    
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.85);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  // Speech-to-Text
  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onListeningComplete,
  }) async {
    if (!_sttInitialized) await initialize();
    
    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          onListeningComplete();
        }
      },
      localeId: 'id_ID',
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async => _stt.stop();
  bool get isListening => _stt.isListening;

  // Text-to-Speech
  Future<void> speak(String text) async {
    // Bersihkan teks dari karakter khusus sebelum diucapkan
    final cleanText = text
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('`', '');
    await _tts.speak(cleanText);
  }

  Future<void> stopSpeaking() async => _tts.stop();

  void dispose() {
    _tts.stop();
    _stt.stop();
  }
}
