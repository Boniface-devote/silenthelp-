import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PhraseRow extends StatelessWidget {
  final String text;
  final Color accentColor;
  final VoidCallback onPlay;
  final VoidCallback onTap;

  const PhraseRow({
    Key? key,
    required this.text,
    required this.accentColor,
    required this.onPlay,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: AppColors.background,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
