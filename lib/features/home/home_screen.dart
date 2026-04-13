import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/language_bar.dart';
import '../../shared/widgets/feature_card.dart';
import '../../shared/providers/locale_provider.dart';
import '../../features/settings/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SILENTHELP',
          style: AppTextStyles.heading2,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () {
                context.go(AppConstants.routeSettings);
              },
              child: Icon(
                Icons.settings,
                size: 28.sp,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Bar
              LanguageBar(),
              
              SizedBox(height: 24.h),

              // Greeting section
              profileAsync.when(
                data: (profile) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTimeBasedGreeting(context),
                      style: AppTextStyles.caption,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      profile.name,
                      style: AppTextStyles.heading1,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      context.tr('home_sub'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                loading: () => ShimmerLoader(),
                error: (err, stack) => Text('Error loading profile'),
              ),

              SizedBox(height: 32.h),

              // SOS Button with pulse
              _buildPulsingSosButton(context),

              SizedBox(height: 32.h),

              // Feature Grid (3 items)
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.85,
                children: [
                  // Talk Mode
                  FeatureCard(
                    iconBgColor: AppColors.tealDark,
                    icon: Icon(
                      Icons.mic,
                      color: AppColors.teal,
                      size: 28.sp,
                    ),
                    title: context.tr('talk'),
                    subtitle: context.tr('talk_sub'),
                    onTap: () => context.go(AppConstants.routeTalk),
                  ),
                  // Quick Phrases
                  FeatureCard(
                    iconBgColor: Color(0xFF4D3A0F),
                    icon: Icon(
                      Icons.message,
                      color: AppColors.yellow,
                      size: 28.sp,
                    ),
                    title: context.tr('phrases'),
                    subtitle: context.tr('phrases_sub'),
                    onTap: () => context.go(AppConstants.routePhrases),
                  ),
                  // My ID Card
                  FeatureCard(
                    iconBgColor: Color(0xFF0F1E3A),
                    icon: Icon(
                      Icons.credit_card,
                      color: AppColors.blue,
                      size: 28.sp,
                    ),
                    title: context.tr('my_id'),
                    subtitle: context.tr('my_id_sub'),
                    onTap: () => context.go(AppConstants.routeIdCard),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Learn Signs & Settings Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go(AppConstants.routeLearn),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.school,
                              color: AppColors.purple,
                              size: 32.sp,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              context.tr('learn'),
                              style: AppTextStyles.labelMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go(AppConstants.routeSettings),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.settings,
                              color: AppColors.teal,
                              size: 32.sp,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              context.tr('settings_title'),
                              style: AppTextStyles.labelMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingSosButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(AppConstants.routeEmergency);
      },
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.03).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.h),
          decoration: BoxDecoration(
            color: AppColors.red,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              Text(
                context.tr('sos'),
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                context.tr('sos_sub'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeBasedGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return context.tr('greeting_morning');
    } else if (hour >= 12 && hour < 17) {
      return context.tr('greeting_afternoon');
    } else {
      return context.tr('greeting_evening');
    }
  }
}

class ShimmerLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 12.h,
          width: 80.w,
          color: AppColors.card,
        ),
        SizedBox(height: 8.h),
        Container(
          height: 32.h,
          width: 200.w,
          color: AppColors.card,
        ),
      ],
    );
  }
}
