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
                  // Professional ID Card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header Bar - Teal with title
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SilentHelp',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                context.tr('medical_id'),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.background,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Main Card Content
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24.w),
                          color: AppColors.card,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name and Avatar Section
                              Row(
                                children: [
                                  // Large Avatar
                                  Container(
                                    width: 80.w,
                                    height: 80.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.tealDark,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: AppColors.teal,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.teal,
                                      size: 40.sp,
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.name.toUpperCase(),
                                          style:
                                              AppTextStyles.heading2.copyWith(
                                            color: AppColors.textPrimary,
                                            letterSpacing: 1,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8.h),
                                        // Condition Badge and Blood Type on same line
                                        Row(
                                          children: [
                                            // Condition Badge
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 6.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.blue
                                                      .withOpacity(0.15),
                                                  border: Border.all(
                                                    color: AppColors.blue,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8.r),
                                                ),
                                                child: Text(
                                                  profile.condition.isEmpty
                                                      ? context.tr('id_cond')
                                                      : profile.condition,
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                    color: AppColors.blue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            // Blood Type Badge
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.red
                                                    .withOpacity(0.1),
                                                border: Border.all(
                                                  color: AppColors.red,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    context.tr('blood_key'),
                                                    style: AppTextStyles
                                                        .caption
                                                        .copyWith(
                                                      color:
                                                          AppColors.textMuted,
                                                      fontSize: 8.sp,
                                                    ),
                                                  ),
                                                  Text(
                                                    profile.bloodType.isEmpty
                                                        ? 'N/A'
                                                        : profile.bloodType,
                                                    style: AppTextStyles
                                                        .heading3
                                                        .copyWith(
                                                      color: AppColors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 24.h),

                              // Divider with accent
                              Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.teal.withOpacity(0.3),
                                      AppColors.border,
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // CRITICAL: Communication Info (UgSL)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColors.teal.withOpacity(0.1),
                                  border: Border.all(
                                    color: AppColors.teal,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'I use Ugandan Sign Language (UgSL)',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'Please communicate by:',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    _buildCommunicationMethod('✏️ Writing'),
                                    SizedBox(height: 6.h),
                                    _buildCommunicationMethod('💬 Text message'),
                                    SizedBox(height: 6.h),
                                    _buildCommunicationMethod('🤷 Simple gestures'),
                                  ],
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // Divider with accent
                              Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.teal.withOpacity(0.3),
                                      AppColors.border,
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 24.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildIdField(
                                          context.tr('phone_key'),
                                          profile.phone,
                                          Icons.phone,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildIdField(
                                          context.tr('em_key'),
                                          profile.emContactName,
                                          Icons.person_add,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.h),

                              // Medical Note
                              if (profile.medicalNote.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.note_alt,
                                          color: AppColors.yellow,
                                          size: 18.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          context.tr('note_key'),
                                          style:
                                              AppTextStyles.caption.copyWith(
                                            color: AppColors.textMuted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.yellow
                                            .withOpacity(0.1),
                                        border: Border(
                                          left: BorderSide(
                                            color: AppColors.yellow,
                                            width: 3,
                                          ),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        profile.medicalNote,
                                        style:
                                            AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // Footer Bar
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.r),
                              bottomRight: Radius.circular(20.r),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ID #${profile.name.hashCode.toString().substring(0, 8).toUpperCase()}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                DateTime.now().year.toString(),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildIdField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.teal,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          value.isEmpty ? '—' : value,
          style: AppTextStyles.bodySmall.copyWith(
            color: value.isEmpty ? AppColors.textMuted : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCommunicationMethod(String method) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: Text(
        method,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
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
PROFILE CARD — ${profile.name.toUpperCase()}

I use Ugandan Sign Language (UgSL)
Please communicate by:
✏️ Writing
💬 Text message
🤷 Simple gestures

Emergency Contact:
${profile.emContactName} — ${profile.emContactNumber}

Phone: ${profile.phone}
Blood Type: ${profile.bloodType}
Condition: ${profile.condition}

${profile.medicalNote.isNotEmpty ? 'Medical Note: ${profile.medicalNote}' : ''}

– SilentHelp
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
