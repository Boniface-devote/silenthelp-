import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/services/text_to_speech_service.dart';
import 'talk_provider.dart';

class TalkScreen extends ConsumerStatefulWidget {
  const TalkScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TalkScreen> createState() => _TalkScreenState();
}

class _TalkScreenState extends ConsumerState<TalkScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speechToText;
  late final TextToSpeechService _tts;
  late TextEditingController _inputController;
  late ScrollController _scrollController;
  late AnimationController _micPulse;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _tts = createTextToSpeechService();
    _inputController = TextEditingController();
    _scrollController = ScrollController();
    _micPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    try {
      await _speechToText.initialize(
        onError: (e) => debugPrint('STT error: $e'),
        onStatus: (s) => debugPrint('STT status: $s'),
      );
    } catch (e) {
      debugPrint('STT init error: $e');
    }
  }

  Future<void> _initTts() async {
    await _tts.initialize(language: 'en_US', rate: 0.5);
  }

  @override
  void dispose() {
    _speechToText.stop();
    _tts.stop();
    _inputController.dispose();
    _scrollController.dispose();
    _micPulse.dispose();
    super.dispose();
  }

  // ── Scroll ──────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Mic / STT ───────────────────────────────────────────────────────────

  void _toggleListening() async {
    final notifier = ref.read(talkProvider.notifier);

    if (_speechToText.isListening) {
      // Tap again → stop and commit whatever was transcribed
      HapticFeedback.lightImpact();
      _speechToText.stop();
      _micPulse.stop();
      notifier.setIsListening(false);

      final live = ref.read(talkProvider).liveTranscript;
      if (live.trim().isNotEmpty) {
        notifier.addHearingMessage(live);
        _scrollToBottom();
      } else {
        notifier.setLiveTranscript('');
      }
    } else {
      final available = await _speechToText.initialize();
      if (!available) return;

      HapticFeedback.lightImpact();
      notifier.setIsListening(true);
      _micPulse.repeat(reverse: true);

      _speechToText.listen(
        onResult: (result) {
          notifier.setLiveTranscript(result.recognizedWords);
          _scrollToBottom();

          // Auto-commit when the engine marks a final result
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            _speechToText.stop();
            _micPulse.stop();
            notifier.setIsListening(false);
            notifier.addHearingMessage(result.recognizedWords);
            _scrollToBottom();
          }
        },
      );
    }
  }

  // ── Send (deaf user) ────────────────────────────────────────────────────

  void _sendDeafMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    ref.read(talkProvider.notifier).addDeafMessage(text);
    _tts.speak(text);
    _inputController.clear();
    setState(() {});
    _scrollToBottom();
  }

  // ── Full-screen overlay ─────────────────────────────────────────────────

  void _showFullScreen(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          color: AppColors.background,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Scroll whenever messages or liveTranscript change
    ref.listen<TalkState>(talkProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.liveTranscript != next.liveTranscript) {
        _scrollToBottom();
      }
    });

    final state = ref.watch(talkProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context, state),
      body: Column(
        children: [
          // ── Chat area ──────────────────────────────────────────────────
          Expanded(
            child: _buildMessageList(context, state),
          ),

          // ── Input bar ─────────────────────────────────────────────────
          _buildInputBar(context, state),
        ],
      ),
    );
  }

  // ── App bar ─────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context, TalkState state) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16.w,
      title: Row(
        children: [
          Text(context.tr('talk_title'), style: AppTextStyles.heading2),
          SizedBox(width: 10.w),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: state.isListening
                  ? AppColors.teal
                  : AppColors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              context.tr('live'),
              style: AppTextStyles.labelSmall.copyWith(
                color: state.isListening
                    ? AppColors.background
                    : AppColors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (state.messages.isNotEmpty)
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.textMuted,
              size: 22.sp,
            ),
            tooltip: 'Clear conversation',
            onPressed: () =>
                ref.read(talkProvider.notifier).clearConversation(),
          ),
        SizedBox(width: 4.w),
      ],
    );
  }

  // ── Message list ─────────────────────────────────────────────────────────

  Widget _buildMessageList(BuildContext context, TalkState state) {
    final hasContent =
        state.messages.isNotEmpty || state.liveTranscript.isNotEmpty;

    if (!hasContent) return _buildEmptyState();

    // Extra slot at the end for the live transcript bubble
    final itemCount =
        state.messages.length + (state.liveTranscript.isNotEmpty ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Live transcript appears after all committed messages
        if (index == state.messages.length &&
            state.liveTranscript.isNotEmpty) {
          return _LiveTranscriptBubble(text: state.liveTranscript);
        }

        final msg = state.messages[index];
        return msg.sender == MessageSender.hearing
            ? _HearingBubble(
                message: msg,
                onSpeak: () => _tts.speak(msg.text),
              )
            : _DeafBubble(
                message: msg,
                onSpeak: () => _tts.speak(msg.text),
                onFullScreen: () => _showFullScreen(context, msg.text),
              );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: AppColors.textMuted,
              size: 56.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Tap 🎙 to hear what they say\nor type your reply below',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Input bar ────────────────────────────────────────────────────────────

  Widget _buildInputBar(BuildContext context, TalkState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        8.h,
        12.w,
        MediaQuery.of(context).viewInsets.bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Mic button
            AnimatedBuilder(
              animation: _micPulse,
              builder: (_, __) {
                final glow = state.isListening ? _micPulse.value : 0.0;
                return GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    margin: EdgeInsets.only(bottom: 1.h),
                    decoration: BoxDecoration(
                      color: state.isListening
                          ? AppColors.teal
                          : AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: state.isListening
                            ? AppColors.teal
                            : AppColors.border,
                        width: 2,
                      ),
                      boxShadow: state.isListening
                          ? [
                              BoxShadow(
                                color: AppColors.teal
                                    .withValues(alpha: 0.25 + glow * 0.45),
                                blurRadius: 6 + glow * 10,
                                spreadRadius: glow * 4,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      state.isListening ? Icons.mic : Icons.mic_none,
                      color: state.isListening
                          ? AppColors.background
                          : AppColors.teal,
                      size: 22.sp,
                    ),
                  ),
                );
              },
            ),

            SizedBox(width: 8.w),

            // Text field
            Expanded(
              child: TextField(
                controller: _inputController,
                style: AppTextStyles.bodyMedium,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _sendDeafMessage(),
                decoration: InputDecoration(
                  hintText: context.tr('type_ph'),
                  hintStyle: AppTextStyles.caption,
                  filled: true,
                  fillColor: AppColors.card,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide:
                        const BorderSide(color: AppColors.teal, width: 1.5),
                  ),
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Send button
            GestureDetector(
              onTap: _inputController.text.trim().isEmpty
                  ? null
                  : _sendDeafMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48.w,
                height: 48.w,
                margin: EdgeInsets.only(bottom: 1.h),
                decoration: BoxDecoration(
                  color: _inputController.text.trim().isEmpty
                      ? AppColors.border
                      : AppColors.teal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: AppColors.background,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Bubble widgets
// ════════════════════════════════════════════════════════════════════════════

/// Left bubble — the hearing person's transcribed speech.
class _HearingBubble extends StatelessWidget {
  const _HearingBubble({required this.message, required this.onSpeak});
  final ChatMessage message;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 14.h, right: 64.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender label
            Padding(
              padding: EdgeInsets.only(left: 6.w, bottom: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: AppColors.textMuted, size: 11.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'They said',
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 11.sp),
                  ),
                ],
              ),
            ),
            // Bubble
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text, style: AppTextStyles.bodyMedium),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: onSpeak,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up,
                            color: AppColors.teal, size: 13.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Play aloud',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.teal,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Right bubble — the deaf user's typed reply.
class _DeafBubble extends StatelessWidget {
  const _DeafBubble({
    required this.message,
    required this.onSpeak,
    required this.onFullScreen,
  });
  final ChatMessage message;
  final VoidCallback onSpeak;
  final VoidCallback onFullScreen;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: 14.h, left: 64.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Sender label
            Padding(
              padding: EdgeInsets.only(right: 6.w, bottom: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You',
                    style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard,
                      color: AppColors.textMuted, size: 11.sp),
                ],
              ),
            ),
            // Bubble
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(4.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.background),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fullscreen button
                      GestureDetector(
                        onTap: onFullScreen,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_full,
                              color: AppColors.background
                                  .withValues(alpha: 0.7),
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Show big',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.background
                                    .withValues(alpha: 0.7),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      // Speak button
                      GestureDetector(
                        onTap: onSpeak,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.volume_up,
                              color: AppColors.background
                                  .withValues(alpha: 0.7),
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Speak',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.background
                                    .withValues(alpha: 0.7),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Left bubble shown while the mic is active — animates in real time.
class _LiveTranscriptBubble extends StatelessWidget {
  const _LiveTranscriptBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 14.h, right: 64.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 6.w, bottom: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: AppColors.teal, size: 11.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Listening…',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.teal,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
                border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Text(
                text.isNotEmpty ? text : '…',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle:
                      text.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
