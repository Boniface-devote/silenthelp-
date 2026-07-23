// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'text_to_speech_service.dart';

// ── Web Speech Synthesis JS interop ─────────────────────────────────────────

extension type _SpeechSynthesisUtterance._(JSObject _) implements JSObject {
  external factory _SpeechSynthesisUtterance(String text);
  external set rate(double value);
  external set lang(String value);
  external set volume(double value);
}

@JS('window.speechSynthesis')
external JSObject? get _speechSynthesisObj;

extension type _SpeechSynthesis._(JSObject _) implements JSObject {
  external void speak(_SpeechSynthesisUtterance utterance);
  external void cancel();
}

// ── Service implementation ───────────────────────────────────────────────────

TextToSpeechService createPlatformTextToSpeechService() =>
    _BrowserTtsService();

class _BrowserTtsService implements TextToSpeechService {
  double _rate = 0.5;
  String _lang = 'en-US';

  _SpeechSynthesis? get _synth {
    try {
      final obj = _speechSynthesisObj;
      if (obj == null) return null;
      return obj as _SpeechSynthesis;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> initialize({
    String language = 'en_US',
    double rate = 0.5,
  }) async {
    _rate = rate;
    _lang = language.replaceAll('_', '-');
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      final synth = _synth;
      if (synth == null) return;
      synth.cancel();
      final utterance = _SpeechSynthesisUtterance(text);
      utterance.rate = _rate;
      utterance.lang = _lang;
      utterance.volume = 1.0;
      synth.speak(utterance);
    } catch (_) {
      // Browser may block speech without a user gesture or lack API support
    }
  }

  @override
  Future<void> stop() async {
    try {
      _synth?.cancel();
    } catch (_) {}
  }
}
