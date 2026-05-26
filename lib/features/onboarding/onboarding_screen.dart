import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      context.go(AppConstants.routeHome);
    }
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildWelcomePage(),
              _buildSOSPage(),
              _buildProfilePage(),
              _buildLanguagePage(),
              _buildPhrasesPage(),
            ],
          ),
          // Top Skip Button
          Positioned(
            top: 20.h,
            right: 20.w,
            child: SafeArea(
              child: GestureDetector(
                onTap: _skipOnboarding,
                child: Text(
                  context.tr('onboarding_skip'),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
                color: AppColors.surface,
              ),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: index == _currentPage ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? AppColors.teal
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),
                  // Buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.card,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                side: BorderSide(color: AppColors.border),
                              ),
                            ),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(
                              context.tr('onboarding_back'),
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      if (_currentPage > 0) SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: _nextPage,
                          child: Text(
                            _currentPage == 4
                                ? context.tr('onboarding_start')
                                : context.tr('onboarding_next'),
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              Icons.waving_hand,
              size: 60.sp,
              color: AppColors.teal,
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            context.tr('onboarding_welcome_title'),
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            context.tr('onboarding_welcome_subtitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              context.tr('onboarding_welcome_desc'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSPage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              Icons.emergency,
              size: 60.sp,
              color: AppColors.red,
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            context.tr('onboarding_sos_title'),
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            context.tr('onboarding_sos_subtitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ..._buildStepsList([
            context.tr('onboarding_sos_step1'),
            context.tr('onboarding_sos_step2'),
            context.tr('onboarding_sos_step3'),
          ]),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              Icons.person,
              size: 60.sp,
              color: AppColors.purple,
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            context.tr('onboarding_profile_title'),
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            context.tr('onboarding_profile_subtitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ..._buildStepsList([
            context.tr('onboarding_profile_step1'),
            context.tr('onboarding_profile_step2'),
            context.tr('onboarding_profile_step3'),
          ]),
        ],
      ),
    );
  }

  Widget _buildLanguagePage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              Icons.language,
              size: 60.sp,
              color: AppColors.blue,
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            context.tr('onboarding_language_title'),
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            context.tr('onboarding_language_subtitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  context.tr('onboarding_language_desc'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  '🇬🇧 English  •  🇹🇿 Kiswahili  •  🇺🇬 Luganda',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhrasesPage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              Icons.message,
              size: 60.sp,
              color: AppColors.yellow,
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            context.tr('onboarding_phrases_title'),
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            context.tr('onboarding_phrases_subtitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: [
              _buildCategoryBadge(
                context.tr('cat_emergency'),
                AppColors.red,
              ),
              _buildCategoryBadge(
                context.tr('cat_daily'),
                AppColors.teal,
              ),
              _buildCategoryBadge(
                context.tr('cat_medical'),
                AppColors.blue,
              ),
              _buildCategoryBadge(
                context.tr('cat_shopping'),
                AppColors.yellow,
              ),
              _buildCategoryBadge(
                context.tr('cat_office'),
                AppColors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildStepsList(List<String> steps) {
    return steps.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final step = entry.value;
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  step,
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
