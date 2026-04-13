import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/language_bar.dart';
import '../../shared/widgets/phrase_row.dart';
import '../../shared/providers/locale_provider.dart';
import 'phrases_data.dart';

class PhrasesScreen extends ConsumerStatefulWidget {
  const PhrasesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends ConsumerState<PhrasesScreen> {
  late FlutterTts _tts;
  String _selectedCategory = 'emergency';

  final List<String> _categories = [
    'emergency',
    'daily',
    'medical',
    'shopping',
  ];

  final Map<String, Color> _categoryColors = {
    'emergency': AppColors.red,
    'daily': AppColors.teal,
    'medical': AppColors.blue,
    'shopping': AppColors.yellow,
  };

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initializeTts();
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
    _tts.stop();
    super.dispose();
  }

  Future<void> _speakPhrase(String phrase) async {
    await _tts.speak(phrase);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final language = currentLocale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('phrases_title'),
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

            // Category Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isActive = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isActive
                            ? _categoryColors[category] ?? AppColors.teal
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isActive
                              ? _categoryColors[category] ?? AppColors.teal
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        context.tr('cat_${category}'),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isActive
                              ? AppColors.background
                              : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 24.h),

            // Phrase List
            ..._buildPhraseList(language),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPhraseList(String language) {
    final phrases = PhrasesData.phrases[_selectedCategory] ?? [];
    final color = _categoryColors[_selectedCategory] ?? AppColors.teal;

    return phrases.asMap().entries.map((entry) {
      final index = entry.key;
      final phraseText = entry.value;
      final parts = phraseText.split('|');
      final langIndex = language == 'en' ? 0 : language == 'sw' ? 1 : 2;
      final displayPhrase =
          langIndex < parts.length ? parts[langIndex] : parts[0];

      return PhraseRow(
        text: displayPhrase,
        accentColor: color,
        onPlay: () => _speakPhrase(displayPhrase),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('copied')),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      );
    }).toList();
  }
}
