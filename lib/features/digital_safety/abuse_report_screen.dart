import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/sms_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../settings/settings_provider.dart';

class AbuseReportScreen extends ConsumerStatefulWidget {
  const AbuseReportScreen({super.key});

  @override
  ConsumerState<AbuseReportScreen> createState() => _AbuseReportScreenState();
}

class _AbuseReportScreenState extends ConsumerState<AbuseReportScreen> {
  static const _categories = <String>[
    'report_category_harassment',
    'report_category_stalking',
    'report_category_impersonation',
    'report_category_threats',
    'report_category_image_abuse',
    'report_category_other',
  ];

  final _detailsController = TextEditingController();
  String? _category;
  String? _recipientNumber;
  bool _includeDetails = false;
  bool _sending = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(context.tr('report_title'), style: AppTextStyles.heading2),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            Center(child: Text(context.tr('report_contacts_error'))),
        data: (profile) {
          final contacts = _trustedContacts(profile);
          if (contacts.isEmpty) {
            return _noContacts(context);
          }
          if (_recipientNumber != null &&
              !contacts.any((contact) => contact.number == _recipientNumber)) {
            _recipientNumber = null;
          }

          return ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.yellow.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  context.tr('report_privacy_notice'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                context.tr('report_what_happened'),
                style: AppTextStyles.labelLarge,
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  filled: true,
                  labelText: context.tr('report_category_label'),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(context.tr(category)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _detailsController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  filled: true,
                  labelText: context.tr('report_optional_details'),
                  hintText: context.tr('report_details_hint'),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _recipientNumber,
                decoration: InputDecoration(
                  filled: true,
                  labelText: context.tr('report_recipient_label'),
                  hintText: context.tr('report_recipient_hint'),
                ),
                items: contacts
                    .map(
                      (contact) => DropdownMenuItem(
                        value: contact.number,
                        child: Text('${contact.name} · ${contact.number}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _recipientNumber = value),
              ),
              SizedBox(height: 12.h),
              CheckboxListTile(
                value: _includeDetails,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.teal,
                title: Text(context.tr('report_include_details')),
                subtitle: Text(context.tr('report_details_toggle_hint')),
                onChanged: (value) =>
                    setState(() => _includeDetails = value ?? false),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : () => _reviewAndSend(contacts),
                  icon: _sending
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.preview_outlined),
                  label: Text(
                    context.tr(_sending ? 'report_preparing' : 'report_review'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: AppColors.textPrimary,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                context.tr('report_evidence_note'),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_ReportContact> _trustedContacts(UserProfile profile) {
    final contacts = <_ReportContact>[
      _ReportContact(profile.emContactName, profile.emContactNumber),
      _ReportContact(profile.secondContactName, profile.secondContactNumber),
      _ReportContact(profile.medicalContactName, profile.medicalContactNumber),
    ];
    final seen = <String>{};
    return contacts
        .where((contact) => contact.number.trim().isNotEmpty)
        .where((contact) => seen.add(contact.number.trim()))
        .toList();
  }

  Widget _noContacts(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, color: AppColors.yellow, size: 42.sp),
            SizedBox(height: 12.h),
            Text(
              context.tr('report_no_contacts_title'),
              style: AppTextStyles.heading2,
            ),
            SizedBox(height: 8.h),
            Text(
              context.tr('report_no_contacts_body'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: () => context.go(AppConstants.routeProfile),
              child: Text(context.tr('report_open_profile')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reviewAndSend(List<_ReportContact> contacts) async {
    final category = _category;
    _ReportContact? recipient;
    for (final contact in contacts) {
      if (contact.number == _recipientNumber) {
        recipient = contact;
        break;
      }
    }
    if (category == null || recipient == null) {
      _showMessage(context.tr('report_choose_category_contact'));
      return;
    }
    final selectedRecipient = recipient;

    final details = _includeDetails ? _detailsController.text.trim() : '';
    final timestamp = DateTime.now().toLocal().toString().substring(0, 16);
    final report = StringBuffer()
      ..writeln(context.tr('report_sms_heading'))
      ..writeln('${context.tr('report_sms_category')}: ${context.tr(category)}')
      ..writeln('${context.tr('report_sms_time')}: $timestamp');
    if (details.isNotEmpty) {
      report.writeln('${context.tr('report_sms_details')}: $details');
    }
    report.write(context.tr('report_sms_request'));
    final message = report.toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('report_review_title')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${context.tr('report_review_to')}: ${selectedRecipient.name} (${selectedRecipient.number})',
              ),
              SizedBox(height: 12.h),
              SelectableText(message),
              SizedBox(height: 12.h),
              Text(context.tr('report_sms_visibility_warning')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('report_send')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _sending = true);
    try {
      final result = await SmsService.sendSms(
        phone: selectedRecipient.number,
        message: message,
      );
      if (!mounted) return;
      if (result.sent) {
        _showMessage(
          result.deliveryConfirmed
              ? context.tr('report_sms_delivered')
              : context.tr('report_sms_unconfirmed'),
        );
      } else if (result.status == 'sms_app_opened') {
        _showMessage(context.tr('report_sms_opened'));
      } else {
        _showMessage(result.errorMessage ?? context.tr('report_sms_failed'));
      }
    } on SmsPermissionException {
      if (mounted) {
        _showMessage(context.tr('report_sms_permission_error'));
      }
    } catch (_) {
      if (mounted) _showMessage(context.tr('report_send_error'));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReportContact {
  const _ReportContact(String name, this.number)
    : name = name == '' ? 'Trusted contact' : name;

  final String name;
  final String number;
}
