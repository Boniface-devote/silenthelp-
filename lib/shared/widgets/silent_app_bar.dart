import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

class SilentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSettingsIcon;

  const SilentAppBar({
    Key? key,
    required this.title,
    this.showSettingsIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: AppTextStyles.heading2,
      ),
      actions: showSettingsIcon
          ? [
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
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
