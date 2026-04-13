import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/language_bar.dart';
import '../settings/settings_provider.dart';

class IdCardScreen extends ConsumerWidget {
  const IdCardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('id_title'),
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

            // ID Card
            profileAsync.when(
              data: (profile) => Column(
                children: [
                  // Card Display
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.teal,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row with avatar and name
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                color: AppColors.tealDark,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.person,
                                color: AppColors.teal,
                                size: 32.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    style: AppTextStyles.heading3,
                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.teal,
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      context.tr('id_cond'),
                                      style:
                                          AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Divider
                        Divider(color: AppColors.border),

                        SizedBox(height: 16.h),

                        // Fields
                        _buildCardField(
                          context.tr('phone_key'),
                          profile.phone,
                        ),
                        SizedBox(height: 12.h),
                        _buildCardField(
                          context.tr('blood_key'),
                          profile.bloodType,
                        ),
                        SizedBox(height: 12.h),
                        _buildCardField(
                          context.tr('em_key'),
                          profile.emContactName,
                        ),
                        SizedBox(height: 12.h),
                        _buildCardField(
                          context.tr('note_key'),
                          profile.medicalNote,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // QR Code
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          context.tr('scan_lbl'),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: PrettyQrView.data(
                            data: jsonEncode({
                              'name': profile.name,
                              'phone': profile.phone,
                              'condition': profile.condition,
                              'bloodType': profile.bloodType,
                              'medicalNote': profile.medicalNote,
                              'emContact': profile.emContactName,
                              'emPhone': profile.emContactNumber,
                            }),
                            decoration: const PrettyQrDecoration(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () =>
                          _shareViaSMS(context, profile),
                      child: Text(
                        context.tr('share_sms'),
                        style: AppTextStyles.buttonLarge.copyWith(
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => Text('Error loading profile'),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCardField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Future<void> _shareViaSMS(
      BuildContext context, UserProfile profile) async {
    final message = '''
SilentHelp Profile Card:
Name: ${profile.name}
Condition: ${profile.condition}
Phone: ${profile.phone}
Blood Type: ${profile.bloodType}
Medical Note: ${profile.medicalNote}
Emergency Contact: ${profile.emContactName} (${profile.emContactNumber})
    ''';

    final Uri smsUri = Uri(
      scheme: 'sms',
      queryParameters: {'body': message},
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open SMS')),
      );
    }
  }
}
