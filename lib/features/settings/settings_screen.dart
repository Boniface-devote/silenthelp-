import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/language_bar.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _conditionController;
  late TextEditingController _phoneController;
  late TextEditingController _bloodController;
  late TextEditingController _noteController;
  late TextEditingController _emNameController;
  late TextEditingController _emPhoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _conditionController = TextEditingController();
    _phoneController = TextEditingController();
    _bloodController = TextEditingController();
    _noteController = TextEditingController();
    _emNameController = TextEditingController();
    _emPhoneController = TextEditingController();
    
    // Set initial values from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileAsync = ref.read(settingsProvider);
      profileAsync.whenData((profile) {
        _nameController.text = profile.name;
        _conditionController.text = profile.condition;
        _phoneController.text = profile.phone;
        _bloodController.text = profile.bloodType;
        _noteController.text = profile.medicalNote;
        _emNameController.text = profile.emContactName;
        _emPhoneController.text = profile.emContactNumber;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
    _phoneController.dispose();
    _bloodController.dispose();
    _noteController.dispose();
    _emNameController.dispose();
    _emPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go(AppConstants.routeHome),
        ),
        centerTitle: true,
        title: Text(
          context.tr('settings_title'),
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
            
            SizedBox(height: 32.h),

            // Personal Details Section
            Text(
              context.tr('lbl_personal'),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _nameController,
              label: context.tr('lbl_name'),
            ),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _conditionController,
              label: context.tr('lbl_cond'),
            ),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _phoneController,
              label: context.tr('lbl_phone'),
            ),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _bloodController,
              label: context.tr('lbl_blood'),
            ),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _noteController,
              label: context.tr('lbl_note'),
              maxLines: 3,
            ),

            SizedBox(height: 32.h),

            // Emergency Contact Section
            Text(
              context.tr('lbl_contacts'),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _emNameController,
              label: context.tr('lbl_em_name'),
            ),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _emPhoneController,
              label: context.tr('lbl_em_num'),
            ),

            SizedBox(height: 32.h),

            // Save Button
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
                onPressed: _saveProfile,
                child: Text(
                  context.tr('save_btn'),
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.background,
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.teal,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
      ],
    );
  }

  void _saveProfile() async {
    final profile = UserProfile(
      name: _nameController.text,
      condition: _conditionController.text,
      phone: _phoneController.text,
      bloodType: _bloodController.text,
      medicalNote: _noteController.text,
      emContactName: _emNameController.text,
      emContactNumber: _emPhoneController.text,
    );

    await ref
        .read(settingsProvider.notifier)
        .saveProfile(profile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('profile_saved')),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back to home
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go(AppConstants.routeHome);
        }
      });
    }
  }
}
