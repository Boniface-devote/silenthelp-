import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DigitalSafetyScreen extends StatelessWidget {
  const DigitalSafetyScreen({super.key});

  static const _guidance = <_SafetyTip>[
    _SafetyTip(
      icon: Icons.lock_outline,
      titleKey: 'digital_protect_title',
      detailKey: 'digital_protect_body',
    ),
    _SafetyTip(
      icon: Icons.visibility_off_outlined,
      titleKey: 'digital_privacy_title',
      detailKey: 'digital_privacy_body',
    ),
    _SafetyTip(
      icon: Icons.block_outlined,
      titleKey: 'digital_harassment_title',
      detailKey: 'digital_harassment_body',
    ),
    _SafetyTip(
      icon: Icons.photo_camera_back_outlined,
      titleKey: 'digital_image_title',
      detailKey: 'digital_image_body',
    ),
    _SafetyTip(
      icon: Icons.fact_check_outlined,
      titleKey: 'digital_pause_title',
      detailKey: 'digital_pause_body',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          context.tr('digital_safety_title'),
          style: AppTextStyles.heading2,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              context.tr('digital_safety_intro'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          for (final tip in _guidance) ...[
            _TipCard(tip: tip),
            SizedBox(height: 10.h),
          ],
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppConstants.routeAbuseReport),
              icon: const Icon(Icons.flag_outlined),
              label: Text(context.tr('digital_report_button')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: AppColors.textPrimary,
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            context.tr('digital_emergency_note'),
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _SafetyTip {
  const _SafetyTip({
    required this.icon,
    required this.titleKey,
    required this.detailKey,
  });

  final IconData icon;
  final String titleKey;
  final String detailKey;
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final _SafetyTip tip;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(tip.icon, color: AppColors.purple, size: 23.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(tip.titleKey),
                    style: AppTextStyles.labelLarge,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    context.tr(tip.detailKey),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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
