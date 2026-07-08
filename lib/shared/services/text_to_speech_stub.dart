import 'text_to_speech_service.dart';

TextToSpeechService createPlatformTextToSpeechService() => WebTextToSpeechService();

class WebTextToSpeechService implements TextToSpeechService {
  @override
  Future<void> initialize({String language = 'en_US', double rate = 0.5}) async {}

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}
