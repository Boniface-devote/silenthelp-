import 'text_to_speech_impl.dart'
    if (dart.library.js_interop) 'text_to_speech_stub.dart';

abstract class TextToSpeechService {
  Future<void> initialize({String language = 'en_US', double rate = 0.5});
  Future<void> speak(String text);
  Future<void> stop();
}

TextToSpeechService createTextToSpeechService() {
  return createPlatformTextToSpeechService();
}
