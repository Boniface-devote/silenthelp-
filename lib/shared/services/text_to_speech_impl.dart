import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'text_to_speech_service.dart';

TextToSpeechService createPlatformTextToSpeechService() => MobileTextToSpeechService();

class MobileTextToSpeechService implements TextToSpeechService {
  late final FlutterTts _tts;
  Future<void> _initFuture = Future.value();

  MobileTextToSpeechService() {
    WidgetsFlutterBinding.ensureInitialized();
    _tts = FlutterTts();
  }

  @override
  Future<void> initialize({String language = 'en_US', double rate = 0.5}) async {
    _initFuture = _initialize(language: language, rate: rate);
    await _initFuture;
  }

  Future<void> _initialize({required String language, required double rate}) async {
    try {
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(rate);
    } catch (_) {
      // Ignore initialization failures on unsupported platforms.
    }
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) {
      return;
    }
    await _initFuture;
    try {
      await _tts.speak(text);
    } catch (_) {
      // Ignore playback failures on unsupported platforms.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignore stop failures.
    }
  }
}
