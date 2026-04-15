import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/language_bar.dart';
import 'talk_provider.dart';

class TalkScreen extends ConsumerStatefulWidget {
  const TalkScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TalkScreen> createState() => _TalkScreenState();
}

class _TalkScreenState extends ConsumerState<TalkScreen> {
  late stt.SpeechToText _speechToText;
  late FlutterTts _tts;
  late TextEditingController _replyController;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _tts = FlutterTts();
    _replyController = TextEditingController();
    _initializeSpeech();
    _initializeTts();
  }

  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) {
          print('Error: $error');
        },
        onStatus: (status) {
          print('Status: $status');
        },
      );
      if (!available) {
        print('Speech to text not available');
      }
    } catch (e) {
      print('Error initializing speech: $e');
    }
  }

  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage('en_US');
      await _tts.setSpeechRate(0.5);
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    _tts.stop();
    _replyController.dispose();
    super.dispose();
  }

  void _startListening() async {
    if (!_speechToText.isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        // Vibration feedback when starting to listen
        HapticFeedback.lightImpact();
        
        ref.read(talkProvider.notifier).setIsListening(true);
        _speechToText.listen(
          onResult: (result) {
            ref.read(talkProvider.notifier)
                .setTranscribedText(result.recognizedWords);
            
            // Vibration feedback when speech is detected
            if (result.recognizedWords.isNotEmpty) {
              HapticFeedback.mediumImpact();
            }
          },
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    // Vibration feedback when stopping listening
    HapticFeedback.lightImpact();
    
    _speechToText.stop();
    ref.read(talkProvider.notifier).setIsListening(false);
  }

  Future<void> _speakText(String text) async {
    if (text.isNotEmpty) {
      await _tts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final talkState = ref.watch(talkProvider);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('talk_title'),
          style: AppTextStyles.heading2,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Bar
            LanguageBar(),

            SizedBox(height: 24.h),

            // Live Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                context.tr('live'),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // They Said Box
            Text(
              context.tr('they_said'),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 8.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                talkState.transcribedText,
                style: talkState.transcribedText ==
                        context.tr('listening')
                    ? AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      )
                    : AppTextStyles.bodyMedium,
              ),
            ),

            SizedBox(height: 24.h),

            // Mic Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Speaker Button
                GestureDetector(
                  onTap: () =>
                      _speakText(talkState.transcribedText),
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Icon(
                      Icons.volume_up,
                      color: AppColors.teal,
                      size: 28.sp,
                    ),
                  ),
                ),
                // Main Mic Button
                GestureDetector(
                  onTap: talkState.isListening
                      ? _stopListening
                      : _startListening,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(40.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      talkState.isListening ? Icons.mic : Icons.mic_none,
                      color: AppColors.background,
                      size: 36.sp,
                    ),
                  ),
                ),
                // Waveform Button (placeholder)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Icon(
                      Icons.equalizer,
                      color: AppColors.teal,
                      size: 28.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Hint Text
            Center(
              child: Text(
                context.tr('hint'),
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 32.h),

            // Your Reply Box
            Text(
              context.tr('your_reply'),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 8.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                talkState.userReply.isEmpty
                    ? ''
                    : talkState.userReply,
                style: AppTextStyles.bodyMedium,
              ),
            ),

            SizedBox(height: 32.h),

            // Text Input & Buttons
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    style: AppTextStyles.bodyMedium,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: context.tr('type_ph'),
                      hintStyle: AppTextStyles.caption,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: AppColors.teal,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Speak button (always active - hear what's being typed)
                GestureDetector(
                  onTap: () => _speakText(_replyController.text),
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Icon(
                      Icons.volume_up,
                      color: AppColors.background,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Send button (submit message)
                GestureDetector(
                  onTap: _replyController.text.isEmpty
                      ? null
                      : () {
                          final reply = _replyController.text;
                          ref.read(talkProvider.notifier).setUserReply(reply);
                          _speakText(reply);
                          _replyController.clear();
                          setState(() {});
                        },
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: _replyController.text.isEmpty
                          ? AppColors.border
                          : AppColors.teal,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Icon(
                      Icons.send,
                      color: AppColors.background,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
