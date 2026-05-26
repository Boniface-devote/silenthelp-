import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/sign_video_player.dart';
import '../../shared/providers/locale_provider.dart';

class Sign {
  final String enTitle;
  final String enSubtitle;
  final String swTitle;
  final String swSubtitle;
  final String lgTitle;
  final String lgSubtitle;
  final String description;
  final String videoPath;

  Sign({
    required this.enTitle,
    required this.enSubtitle,
    required this.swTitle,
    required this.swSubtitle,
    required this.lgTitle,
    required this.lgSubtitle,
    required this.description,
    required this.videoPath,
  });
}

class LearnScreen extends ConsumerWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final language = currentLocale.languageCode;

    final signs = [
      Sign(
        enTitle: 'Hello',
        enSubtitle: 'Greeting sign',
        swTitle: 'Hujambo',
        swSubtitle: 'Ishara ya kumkaribisha',
        lgTitle: 'Nkusanyukidde',
        lgSubtitle: 'Ensonyiwa ya okukaakasa',
        description:
            'Open your hand, palm outward, and wave side to side in front of your face.',
        videoPath: 'assets/videos/hello.mp4',
      ),
      Sign(
        enTitle: 'Help',
        enSubtitle: 'Assistance sign',
        swTitle: 'Msaada',
        swSubtitle: 'Ishara ya msaada',
        lgTitle: 'Obuyamba',
        lgSubtitle: 'Ensonyiwa ya obuyamba',
        description:
            'Place your hands as if you are lifting something, and move them upward together.',
        videoPath: 'assets/videos/help.mp4',
      ),
      Sign(
        enTitle: 'My name is...',
        enSubtitle: 'Introduction sign',
        swTitle: 'Jina langu ni...',
        swSubtitle: 'Ishara ya kujifahamisha',
        lgTitle: 'Erinnya lyange...',
        lgSubtitle: 'Ensonyiwa ya okutambula',
        description:
            'Point to yourself with both index fingers, then finger spell your name.',
        videoPath: 'assets/videos/my_name_is.mp4',
      ),
      Sign(
        enTitle: 'Thank you',
        enSubtitle: 'Gratitude sign',
        swTitle: 'Asante',
        swSubtitle: 'Ishara ya shukrani',
        lgTitle: 'Webale',
        lgSubtitle: 'Ensonyiwa ya ssanyu',
        description:
            'Move your open hand from your chin outward in a graceful motion.',
        videoPath: 'assets/videos/thank_you.mp4',
      ),
      Sign(
        enTitle: 'I am deaf',
        enSubtitle: 'Identity sign',
        swTitle: 'Mimi ni bubu',
        swSubtitle: 'Ishara ya utambulisho',
        lgTitle: 'Nsimu',
        lgSubtitle: 'Ensonyiwa ya tutambuliddiriza',
        description:
            'Point to your ear and shake your head, then point to yourself.',
        videoPath: 'assets/videos/i_am_deaf.mp4',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('learn_title'),
          style: AppTextStyles.heading2,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                context.tr('learn_badge'),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Sign Cards
            ...signs.map((sign) {
              return _buildSignCard(context, sign, language);
            }).toList(),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSignCard(BuildContext context, Sign sign, String language) {
    final title = language == 'en'
        ? sign.enTitle
        : language == 'sw'
            ? sign.swTitle
            : sign.lgTitle;

    final subtitle = language == 'en'
        ? sign.enSubtitle
        : language == 'sw'
            ? sign.swSubtitle
            : sign.lgSubtitle;

    return GestureDetector(
      onTap: () {
        _showSignDetails(context, title, sign.description, sign.videoPath);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.pan_tool,
                color: AppColors.purple,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            // Play Button
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.background,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignDetails(
    BuildContext context,
    String title,
    String description,
    String videoPath,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.heading2,
              ),
              SizedBox(height: 16.h),
              SignVideoPlayer(videoAssetPath: videoPath),
              SizedBox(height: 16.h),
              Text(
                'How to perform:',
                style: AppTextStyles.labelMedium,
              ),
              SizedBox(height: 8.h),
              Text(
                description,
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.background,
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
}
