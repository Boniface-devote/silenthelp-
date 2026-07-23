import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/providers/locale_provider.dart';
import '../../shared/services/text_to_speech_service.dart';
import 'phrases_data.dart';

// ── Category meta ─────────────────────────────────────────────────────────────

class _Category {
  final String key;
  final IconData icon;
  final Color color;
  const _Category({required this.key, required this.icon, required this.color});
}

const _categories = [
  _Category(key: 'emergency',  icon: Icons.emergency_rounded,       color: AppColors.red),
  _Category(key: 'daily',      icon: Icons.wb_sunny_rounded,         color: AppColors.teal),
  _Category(key: 'medical',    icon: Icons.local_hospital_rounded,   color: AppColors.blue),
  _Category(key: 'shopping',   icon: Icons.shopping_bag_rounded,     color: AppColors.yellow),
  _Category(key: 'office',     icon: Icons.work_rounded,             color: AppColors.purple),
  _Category(key: 'transport',  icon: Icons.directions_bus_rounded,   color: Color(0xFF4CAF50)),
  _Category(key: 'restaurant', icon: Icons.restaurant_rounded,       color: Color(0xFFFF8C42)),
  _Category(key: 'bank',       icon: Icons.account_balance_rounded,  color: Color(0xFF9C6AFF)),
  _Category(key: 'school',     icon: Icons.school_rounded,           color: Color(0xFF29B6F6)),
  _Category(key: 'police',     icon: Icons.local_police_rounded,     color: Color(0xFF78909C)),
];

// ════════════════════════════════════════════════════════════════════════════
// Screen
// ════════════════════════════════════════════════════════════════════════════

class PhrasesScreen extends ConsumerStatefulWidget {
  const PhrasesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends ConsumerState<PhrasesScreen> {
  late final TextToSpeechService _tts;
  String _selectedKey = 'emergency';
  bool _showTranslations = false;

  @override
  void initState() {
    super.initState();
    _tts = createTextToSpeechService();
    _tts.initialize(language: 'en_US', rate: 0.5);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  _Category get _activeCat =>
      _categories.firstWhere((c) => c.key == _selectedKey);

  List<String> get _activePhrases =>
      PhrasesData.phrases[_selectedKey] ?? [];

  void _selectCategory(String key) {
    if (key == _selectedKey) return;
    setState(() => _selectedKey = key);
  }

  void _speakPhrase(String text) {
    _tts.speak(text);
    HapticFeedback.selectionClick();
  }

  void _showFullscreen(
      BuildContext context, String phrase, Color accentColor) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          color: AppColors.background,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 6.h,
                color: accentColor,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Show this to them',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(Icons.close,
                            color: AppColors.textPrimary, size: 18.sp),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      phrase,
                      style: TextStyle(
                        fontSize: 44.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(Icons.volume_up_rounded,
                        color: AppColors.background, size: 20.sp),
                    label: Text(
                      'Speak aloud',
                      style: AppTextStyles.buttonMedium
                          .copyWith(color: AppColors.background),
                    ),
                    onPressed: () => _speakPhrase(phrase),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider).languageCode;
    final activeCat = _activeCat;
    final phrases = _activePhrases;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20.w,
        title: Text(context.tr('phrases_title'),
            style: AppTextStyles.heading2),
        actions: [
          GestureDetector(
            onTap: () =>
                setState(() => _showTranslations = !_showTranslations),
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _showTranslations
                    ? AppColors.teal.withValues(alpha: 0.15)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _showTranslations
                      ? AppColors.teal
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate_rounded,
                    size: 14.sp,
                    color: _showTranslations
                        ? AppColors.teal
                        : AppColors.textMuted,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _showTranslations ? 'On' : 'Off',
                    style: AppTextStyles.caption.copyWith(
                      color: _showTranslations
                          ? AppColors.teal
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryBar(context),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
              itemCount: phrases.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSectionHeader(
                      context, activeCat, phrases.length);
                }
                final phraseIndex = index - 1;
                final parts = phrases[phraseIndex].split('|');
                final langIdx =
                    language == 'en' ? 0 : language == 'sw' ? 1 : 2;
                final primary =
                    langIdx < parts.length ? parts[langIdx] : parts[0];
                final en = parts.isNotEmpty ? parts[0] : '';
                final sw = parts.length > 1 ? parts[1] : '';
                final lg = parts.length > 2 ? parts[2] : '';

                return _buildPhraseCard(
                  context: context,
                  primary: primary,
                  en: en,
                  sw: sw,
                  lg: lg,
                  language: language,
                  accentColor: activeCat.color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Category chip bar ─────────────────────────────────────────────────────

  Widget _buildCategoryBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: _categories.map((cat) {
            final isActive = cat.key == _selectedKey;
            final count =
                PhrasesData.phrases[cat.key]?.length ?? 0;
            return GestureDetector(
              onTap: () => _selectCategory(cat.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? cat.color
                      : cat.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: isActive
                        ? cat.color
                        : cat.color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 15.sp,
                      color: isActive
                          ? AppColors.background
                          : cat.color,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      context.tr('cat_${cat.key}'),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isActive
                            ? AppColors.background
                            : cat.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.background
                                .withValues(alpha: 0.25)
                            : cat.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$count',
                        style: AppTextStyles.caption.copyWith(
                          color: isActive
                              ? AppColors.background
                              : cat.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
      BuildContext context, _Category cat, int count) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(cat.icon, color: cat.color, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('cat_${cat.key}').toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$count phrases',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            _showTranslations
                ? 'All languages shown'
                : 'Translations hidden',
            style: AppTextStyles.caption.copyWith(fontSize: 10.sp),
          ),
        ],
      ),
    );
  }

  // ── Phrase card ──────────────────────────────────────────────────────

  Widget _buildPhraseCard({
    required BuildContext context,
    required String primary,
    required String en,
    required String sw,
    required String lg,
    required String language,
    required Color accentColor,
  }) {
    // Collect other-language translations into plain lists (no dart records,
    // no width:infinity, no CrossAxisAlignment.stretch — all caused layout
    // re-entrancy crashes in ListView.builder).
    final List<String> otherLabels = [];
    final List<String> otherTexts  = [];
    if (_showTranslations) {
      if (language != 'en' && en.isNotEmpty) { otherLabels.add('EN'); otherTexts.add(en); }
      if (language != 'sw' && sw.isNotEmpty) { otherLabels.add('SW'); otherTexts.add(sw); }
      if (language != 'lg' && lg.isNotEmpty) { otherLabels.add('LG'); otherTexts.add(lg); }
    }

    return Container(
      // No width:infinity here — the ListView gives tight width constraints
      // so the Container fills naturally without a ConstrainedBox(w=∞).
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Primary phrase ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small accent tag (explicit size — no stretch needed)
                Container(
                  width: 3.w,
                  height: 18.h,
                  margin: EdgeInsets.only(top: 2.h, right: 8.w),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Expanded(
                  child: Text(
                    primary,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () => _showFullscreen(context, primary, accentColor),
                  child: Icon(
                    Icons.open_in_full_rounded,
                    color: accentColor,
                    size: 16.sp,
                  ),
                ),
              ],
            ),

            // ── Other-language translations ───────────────────────────
            if (otherLabels.isNotEmpty) ...[
              SizedBox(height: 10.h),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(otherLabels.length, (i) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: i < otherLabels.length - 1 ? 6.h : 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                otherLabels[i],
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                otherTexts[i],
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],

            // ── Speak button ───────────────────────────────────────
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _speakPhrase(primary),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up_rounded,
                          size: 13.sp, color: AppColors.background),
                      SizedBox(width: 5.w),
                      Text(
                        'Speak',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
