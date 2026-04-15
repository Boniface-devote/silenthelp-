import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/locale_provider.dart';

class LanguageBar extends ConsumerWidget {
  const LanguageBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('language'),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _LanguagePill(
                label: 'EN',
                isActive: currentLocale.languageCode == 'en',
                onTap: () {
                  ref.read(localeProvider.notifier).state = const Locale('en');
                  context.setLocale(const Locale('en'));
                },
              ),
              SizedBox(width: 8.w),
              _LanguagePill(
                label: 'SW',
                isActive: currentLocale.languageCode == 'sw',
                onTap: () {
                  ref.read(localeProvider.notifier).state = const Locale('sw');
                  context.setLocale(const Locale('sw'));
                },
              ),
              SizedBox(width: 8.w),
              _LanguagePill(
                label: 'LG',
                isActive: currentLocale.languageCode == 'lg',
                onTap: () {
                  ref.read(localeProvider.notifier).state = const Locale('lg');
                  context.setLocale(const Locale('lg'));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _LanguagePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.teal : AppColors.card,
          border: Border.all(
            color: isActive ? AppColors.teal : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? AppColors.background : AppColors.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
