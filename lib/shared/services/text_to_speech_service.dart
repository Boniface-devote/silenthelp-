import 'text_to_speech_impl.dart'
    if (dart.library.html) 'text_to_speech_web.dart';

abstract class TextToSpeechService {
  Future<void> initialize({String language = 'en_US', double rate = 0.5});
  Future<void> speak(String text);
  Future<void> stop();
}

TextToSpeechService createTextToSpeechService() =>
    createPlatformTextToSpeechService();
