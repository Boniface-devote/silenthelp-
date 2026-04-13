import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalkState {
  final String transcribedText;
  final bool isListening;
  final String userReply;

  TalkState({
    this.transcribedText = 'Listening for speech...',
    this.isListening = false,
    this.userReply = '',
  });

  TalkState copyWith({
    String? transcribedText,
    bool? isListening,
    String? userReply,
  }) {
    return TalkState(
      transcribedText: transcribedText ?? this.transcribedText,
      isListening: isListening ?? this.isListening,
      userReply: userReply ?? this.userReply,
    );
  }
}

class TalkNotifier extends StateNotifier<TalkState> {
  TalkNotifier() : super(TalkState());

  void setTranscribedText(String text) {
    state = state.copyWith(transcribedText: text);
  }

  void setIsListening(bool listening) {
    state = state.copyWith(isListening: listening);
  }

  void setUserReply(String reply) {
    state = state.copyWith(userReply: reply);
  }

  void reset() {
    state = TalkState();
  }
}

final talkProvider = StateNotifierProvider<TalkNotifier, TalkState>(
  (ref) => TalkNotifier(),
);
