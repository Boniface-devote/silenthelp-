import 'package:flutter_test/flutter_test.dart';
import 'package:silenthelp/shared/services/text_to_speech_service.dart';

void main() {
  test('creates a speech service that can be initialized safely', () async {
    final service = createTextToSpeechService();

    await expectLater(
      service.initialize(language: 'en_US', rate: 0.5),
      completes,
    );

    await expectLater(service.speak('hello'), completes);
    await expectLater(service.stop(), completes);
  });
}
