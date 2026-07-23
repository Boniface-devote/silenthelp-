import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MessageSender { hearing, deaf }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

class TalkState {
  final List<ChatMessage> messages;
  final bool isListening;

  /// Live speech being transcribed — not yet committed to the message list.
  final String liveTranscript;

  const TalkState({
    this.messages = const [],
    this.isListening = false,
    this.liveTranscript = '',
  });

  TalkState copyWith({
    List<ChatMessage>? messages,
    bool? isListening,
    String? liveTranscript,
  }) {
    return TalkState(
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      liveTranscript: liveTranscript ?? this.liveTranscript,
    );
  }
}

class TalkNotifier extends StateNotifier<TalkState> {
  TalkNotifier() : super(const TalkState());

  /// Commit the live transcript as a left (hearing) bubble.
  void addHearingMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          text: trimmed,
          sender: MessageSender.hearing,
          timestamp: DateTime.now(),
        ),
      ],
      liveTranscript: '',
    );
  }

  /// Add a right (deaf user) bubble.
  void addDeafMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          text: trimmed,
          sender: MessageSender.deaf,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  /// Update the live in-progress transcript (not yet a bubble).
  void setLiveTranscript(String text) {
    state = state.copyWith(liveTranscript: text);
  }

  void setIsListening(bool value) {
    state = state.copyWith(isListening: value);
  }

  void clearConversation() {
    state = const TalkState();
  }
}

final talkProvider =
    StateNotifierProvider<TalkNotifier, TalkState>((ref) => TalkNotifier());
