import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_contact_picker_plus/flutter_native_contact_picker_plus.dart';
import 'package:flutter_native_contact_picker_plus/model/contact_model.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/language_bar.dart';
import 'settings_provider.dart';

class ContactSelectionData {
  const ContactSelectionData({required this.name, required this.phoneNumber});

  final String name;
  final String phoneNumber;
}

ContactSelectionData buildContactSelectionData(Contact contact) {
  final contactName = contact.fullName?.trim() ?? '';
  final phoneNumber = contact.phoneNumbers?.isNotEmpty == true
      ? contact.phoneNumbers!.first.trim()
      : '';

  return ContactSelectionData(name: contactName, phoneNumber: phoneNumber);
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static FlutterContactPickerPlus createContactPicker() {
    return FlutterContactPickerPlus();
  }

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _profileLoaded = false;
  bool _profileLoadFailed = false;
  bool _isSaving = false;
  late TextEditingController _nameController;
  late TextEditingController _conditionController;
  late TextEditingController _phoneController;
  late TextEditingController _bloodController;
  late TextEditingController _noteController;
  late TextEditingController _emNameController;
  late TextEditingController _emPhoneController;
  late TextEditingController _secondContactNameController;
  late TextEditingController _secondContactPhoneController;
  late TextEditingController _secondContactLabelController;
  late TextEditingController _medicalContactNameController;
  late TextEditingController _medicalContactPhoneController;
  late TextEditingController _medicalContactLabelController;

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
    _secondContactNameController = TextEditingController();
    _secondContactPhoneController = TextEditingController();
    _secondContactLabelController = TextEditingController(
      text: 'Family / Teacher',
    );
    _medicalContactNameController = TextEditingController();
    _medicalContactPhoneController = TextEditingController();
    _medicalContactLabelController = TextEditingController(
      text: 'Doctor / Nurse / Hospital',
    );

    unawaited(_loadProfile());
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
    _secondContactNameController.dispose();
    _secondContactPhoneController.dispose();
    _secondContactLabelController.dispose();
    _medicalContactNameController.dispose();
    _medicalContactPhoneController.dispose();
    _medicalContactLabelController.dispose();
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Bar
              LanguageBar(),

              if (!_profileLoaded && !_profileLoadFailed)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: const LinearProgressIndicator(),
                ),

              if (_profileLoadFailed)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Text(
                    'Could not load your saved settings. Please restart and try again.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                ),

              SizedBox(height: 32.h),

              // Profile Completion Section
              _buildProfileCompletionWidget(ref),

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
                keyboardType: TextInputType.phone,
                validator: _validateOptionalPhone,
              ),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: _bloodController,
                label: context.tr('lbl_blood'),
                validator: _validateBloodType,
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
                validator: (value) =>
                    _validatePairedContactName(value, _emPhoneController),
              ),
              SizedBox(height: 8.h),
              Semantics(
                button: true,
                label: context.tr('pick_from_contacts'),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: !_profileLoaded || _isSaving
                        ? null
                        : () => _pickContactAndFill(
                            nameController: _emNameController,
                            phoneController: _emPhoneController,
                          ),
                    icon: const Icon(Icons.contacts_outlined),
                    label: Text(context.tr('pick_from_contacts')),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: AppColors.teal),
                      foregroundColor: AppColors.teal,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: _emPhoneController,
                label: context.tr('lbl_em_num'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    _validateContactPhone(value, _emNameController),
              ),

              SizedBox(height: 20.h),
              _buildTextField(
                controller: _secondContactLabelController,
                label: 'Contact Role 2',
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _secondContactNameController,
                label: 'Family / Teacher Contact Name',
                validator: (value) => _validatePairedContactName(
                  value,
                  _secondContactPhoneController,
                ),
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _secondContactPhoneController,
                label: 'Family / Teacher Contact Number',
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    _validateContactPhone(value, _secondContactNameController),
              ),
              SizedBox(height: 8.h),
              Semantics(
                button: true,
                label: context.tr('pick_from_contacts'),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: !_profileLoaded || _isSaving
                        ? null
                        : () => _pickContactAndFill(
                            nameController: _secondContactNameController,
                            phoneController: _secondContactPhoneController,
                          ),
                    icon: const Icon(Icons.contacts_outlined),
                    label: Text(context.tr('pick_from_contacts')),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: AppColors.teal),
                      foregroundColor: AppColors.teal,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              _buildTextField(
                controller: _medicalContactLabelController,
                label: 'Medical Contact Role',
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _medicalContactNameController,
                label: 'Doctor / Nurse / Hospital Name',
                validator: (value) => _validatePairedContactName(
                  value,
                  _medicalContactPhoneController,
                ),
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _medicalContactPhoneController,
                label: 'Doctor / Nurse / Hospital Number',
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    _validateContactPhone(value, _medicalContactNameController),
              ),
              SizedBox(height: 8.h),
              Semantics(
                button: true,
                label: context.tr('pick_from_contacts'),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: !_profileLoaded || _isSaving
                        ? null
                        : () => _pickContactAndFill(
                            nameController: _medicalContactNameController,
                            phoneController: _medicalContactPhoneController,
                          ),
                    icon: const Icon(Icons.contacts_outlined),
                    label: Text(context.tr('pick_from_contacts')),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: AppColors.teal),
                      foregroundColor: AppColors.teal,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // SOS History Section
              _buildSOSHistorySection(ref),

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
                  onPressed: !_profileLoaded || _isSaving ? null : _saveProfile,
                  child: Text(
                    _isSaving ? 'Saving…' : context.tr('save_btn'),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          enabled: _profileLoaded && !_isSaving,
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
              borderSide: const BorderSide(color: AppColors.teal, width: 2),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
      ],
    );
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(settingsProvider.future);
      if (!mounted) return;

      _nameController.text = profile.name;
      _conditionController.text = profile.condition;
      _phoneController.text = profile.phone;
      _bloodController.text = profile.bloodType;
      _noteController.text = profile.medicalNote;
      _emNameController.text = profile.emContactName;
      _emPhoneController.text = profile.emContactNumber;
      _secondContactNameController.text = profile.secondContactName;
      _secondContactPhoneController.text = profile.secondContactNumber;
      _secondContactLabelController.text = profile.secondContactLabel.isNotEmpty
          ? profile.secondContactLabel
          : 'Family / Teacher';
      _medicalContactNameController.text = profile.medicalContactName;
      _medicalContactPhoneController.text = profile.medicalContactNumber;
      _medicalContactLabelController.text =
          profile.medicalContactLabel.isNotEmpty
          ? profile.medicalContactLabel
          : 'Doctor / Nurse / Hospital';
      setState(() => _profileLoaded = true);
    } catch (_) {
      if (mounted) setState(() => _profileLoadFailed = true);
    }
  }

  String? _validateOptionalPhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\+?[0-9 ()-]+$').hasMatch(phone) ||
        digits.length < 7 ||
        digits.length > 15) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  String? _validateContactPhone(
    String? value,
    TextEditingController nameController,
  ) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty && nameController.text.trim().isNotEmpty) {
      return 'Enter a phone number for this contact.';
    }
    return _validateOptionalPhone(phone);
  }

  String? _validatePairedContactName(
    String? value,
    TextEditingController phoneController,
  ) {
    if ((value?.trim().isNotEmpty ?? false) &&
        phoneController.text.trim().isEmpty) {
      return 'Enter a phone number for this contact.';
    }
    return null;
  }

  String? _validateBloodType(String? value) {
    final bloodType = value?.trim().toUpperCase() ?? '';
    if (bloodType.isEmpty || bloodType == '??' || bloodType == 'UNKNOWN') {
      return null;
    }
    const bloodTypes = {'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'};
    if (!bloodTypes.contains(bloodType)) {
      return 'Enter a valid blood type, such as O+ or A-.';
    }
    return null;
  }

  Future<void> _pickContactAndFill({
    required TextEditingController nameController,
    required TextEditingController phoneController,
  }) async {
    final currentStatus = await Permission.contacts.status;
    final permissionStatus = currentStatus.isGranted
        ? currentStatus
        : await Permission.contacts.request();

    if (!permissionStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('contacts_permission_denied')),
            backgroundColor: AppColors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      final contactPicker = SettingsScreen.createContactPicker();
      final contact = await contactPicker.selectContact();

      if (contact == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('contacts_no_selection')),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final selection = buildContactSelectionData(contact);

      if (mounted) {
        setState(() {
          nameController.text = selection.name;
          phoneController.text = selection.phoneNumber;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('contacts_selected')),
            backgroundColor: AppColors.teal,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('contacts_pick_error')),
            backgroundColor: AppColors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving || !_profileLoaded) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profile = UserProfile(
      name: _nameController.text.trim(),
      condition: _conditionController.text.trim(),
      phone: _phoneController.text.trim(),
      bloodType: _bloodController.text.trim().toUpperCase(),
      medicalNote: _noteController.text.trim(),
      emContactName: _emNameController.text.trim(),
      emContactNumber: _emPhoneController.text.trim(),
      secondContactName: _secondContactNameController.text.trim(),
      secondContactNumber: _secondContactPhoneController.text.trim(),
      secondContactLabel: _secondContactLabelController.text.trim(),
      medicalContactName: _medicalContactNameController.text.trim(),
      medicalContactNumber: _medicalContactPhoneController.text.trim(),
      medicalContactLabel: _medicalContactLabelController.text.trim(),
    );

    setState(() => _isSaving = true);
    try {
      await ref.read(settingsProvider.notifier).saveProfile(profile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('profile_saved')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save settings. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildProfileCompletionWidget(WidgetRef ref) {
    final completionAsync = ref.watch(profileCompletionProvider);

    return completionAsync.when(
      data: (completion) {
        final isIncomplete = completion.completionPercentage < 100;
        final isEmergencyContactMissing =
            !completion.isEmergencyContactComplete;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              context.tr('profile_completion'),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 12.h),

            // Warning if incomplete
            if (isIncomplete)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isEmergencyContactMissing
                      ? AppColors.red.withValues(alpha: 0.15)
                      : AppColors.yellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isEmergencyContactMissing
                        ? AppColors.red
                        : AppColors.yellow,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmergencyContactMissing
                          ? context.tr('incomplete_warning')
                          : context.tr('profile_instructions'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isEmergencyContactMissing
                            ? AppColors.red
                            : AppColors.yellow,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.teal),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.teal,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '✓ Profile Complete',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 12.h),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: completion.completionPercentage / 100,
                minHeight: 8.h,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  completion.completionPercentage < 100
                      ? AppColors.yellow
                      : AppColors.teal,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Percentage Text
            Text(
              '${completion.completionPercentage}% Complete',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: 16.h),

            // Checklist Items
            _buildChecklistItem(
              context.tr('completion_step1'),
              completion.hasName,
            ),
            _buildChecklistItem(
              context.tr('completion_step2'),
              completion.hasPhone,
            ),
            _buildChecklistItem(
              context.tr('completion_step3'),
              completion.hasBloodType,
            ),
            _buildChecklistItem(
              context.tr('completion_step4'),
              completion.hasEmergencyContactName,
              isRequired: true,
            ),
            _buildChecklistItem(
              context.tr('completion_step5'),
              completion.hasEmergencyContactNumber,
              isRequired: true,
            ),
          ],
        );
      },
      loading: () => Container(
        padding: EdgeInsets.all(16.w),
        child: const CircularProgressIndicator(),
      ),
      error: (error, stack) => Text('Error loading profile'),
    );
  }

  Widget _buildChecklistItem(
    String label,
    bool isComplete, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.teal
                  : isRequired
                  ? AppColors.red.withValues(alpha: 0.2)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: isComplete
                    ? AppColors.teal
                    : isRequired
                    ? AppColors.red
                    : AppColors.border,
              ),
            ),
            child: isComplete
                ? Icon(Icons.check, size: 16.sp, color: AppColors.background)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isComplete
                    ? AppColors.textSecondary
                    : isRequired
                    ? AppColors.red
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSHistorySection(WidgetRef ref) {
    final sosLogAsync = ref.watch(sosLogProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('sos_history'),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            // Clear button
            sosLogAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.card,
                        title: Text(
                          context.tr('sos_history'),
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        content: Text(
                          'Clear all SOS history?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(sosLogProvider.notifier).clearLog();
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.tr('sos_history_cleared'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              context.pop();
                            },
                            child: Text(
                              'Clear',
                              style: TextStyle(color: AppColors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    context.tr('sos_clear_history'),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                );
              },
              loading: () => SizedBox.shrink(),
              error: (_, __) => SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Log List
        sosLogAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    context.tr('sos_log_empty'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(logs.length, (index) {
                  final log =
                      logs[logs.length -
                          1 -
                          index]; // Reverse order (newest first)
                  return _buildSOSLogItem(
                    log,
                    index == 0,
                    index == logs.length - 1,
                  );
                }),
              ),
            );
          },
          loading: () => Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: const CircularProgressIndicator(),
          ),
          error: (_, __) => Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('Error loading history'),
          ),
        ),
      ],
    );
  }

  Widget _buildSOSLogItem(SOSLogEntry log, bool isFirst, bool isLast) {
    final isOpened =
        log.status == 'opened_in_sms' || log.status == 'sms_app_opened';
    final isDelivered = log.status == 'delivered';
    final isFailed = log.status == 'failed' || log.status == 'delivery_failed';
    final formattedDate =
        '${log.timestamp.month}/${log.timestamp.day}/${log.timestamp.year} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isOpened
                      ? AppColors.teal.withValues(alpha: 0.2)
                      : AppColors.yellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isOpened ? Icons.check_circle : Icons.schedule,
                  color: isOpened ? AppColors.teal : AppColors.yellow,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      log.message,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isDelivered
                          ? 'Delivered'
                          : isFailed
                          ? 'Failed'
                          : isOpened
                          ? context.tr('sos_log_opened')
                          : context.tr('sos_log_prepared'),
                      style: AppTextStyles.caption.copyWith(
                        color: isDelivered
                            ? AppColors.teal
                            : isFailed
                            ? AppColors.red
                            : isOpened
                            ? AppColors.teal
                            : AppColors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.border,
            indent: 12.w,
            endIndent: 12.w,
          ),
      ],
    );
  }
}
