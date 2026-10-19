import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/contact_row.dart';
import '../../core/services/location_service.dart';
import '../../core/services/haptics_service.dart';
import '../../core/services/sms_service.dart';
import 'emergency_provider.dart';
import '../settings/settings_provider.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  DateTime? _sentAt; // set when SOS is dispatched

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Load cached location on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emergencyProvider.notifier).loadCachedLocation();
      // Start background location refresh in parallel
      ref.read(emergencyProvider.notifier).refreshLocationBackground();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildSafeCheckInCard(
    AsyncValue<UserProfile> profileAsync,
    bool isSending,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('safe_checkin_title'), style: AppTextStyles.heading2),
          SizedBox(height: 4.h),
          Text(
            context.tr('safe_checkin_subtitle'),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSending
                      ? null
                      : () => _sendSafeStatus(profileAsync),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    context.tr(isSending ? 'sending' : 'checkin_safe_button'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSending
                      ? null
                      : () => _requestHelp(profileAsync),
                  icon: const Icon(Icons.support_agent),
                  label: Text(
                    context.tr(isSending ? 'sending' : 'checkin_help_button'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendSafeStatus(AsyncValue<UserProfile> profileAsync) async {
    final profile = profileAsync.valueOrNull;
    if (profile == null) return;
    final contacts = await _chooseCheckInRecipients(
      allContacts: _trustedContacts(profile),
      defaults: _trustedContacts(profile, includeMedical: false),
      title: context.tr('checkin_choose_safe_recipients'),
    );
    if (contacts == null) return;
    await _sendCheckIn(
      contacts: contacts,
      status: context.tr('checkin_status_safe'),
      category: context.tr('risk_none'),
    );
  }

  Future<void> _requestHelp(AsyncValue<UserProfile> profileAsync) async {
    final profile = profileAsync.valueOrNull;
    if (profile == null) return;

    var category = context.tr('risk_abuse');
    var danger = context.tr('danger_support');
    final selection = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.tr('checkin_request_support_title')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('checkin_help_category_prompt')),
                for (final option in [
                  context.tr('risk_abuse'),
                  context.tr('risk_forced_marriage'),
                  context.tr('risk_fgm'),
                  context.tr('risk_other_safety'),
                ])
                  RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(option),
                    value: option,
                    groupValue: category,
                    onChanged: (value) =>
                        setDialogState(() => category = value!),
                  ),
                const SizedBox(height: 8),
                Text(context.tr('checkin_urgency_prompt')),
                for (final option in [
                  context.tr('danger_support'),
                  context.tr('danger_now'),
                ])
                  RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(option),
                    value: option,
                    groupValue: danger,
                    onChanged: (value) => setDialogState(() => danger = value!),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, (category, danger)),
              child: Text(context.tr('continue')),
            ),
          ],
        ),
      ),
    );
    if (selection == null) return;

    final urgent = selection.$2 == context.tr('danger_now');
    final contacts = await _chooseCheckInRecipients(
      allContacts: _trustedContacts(profile),
      defaults: _trustedContacts(profile, includeMedical: urgent),
      title: context.tr('checkin_choose_help_recipients'),
    );
    if (contacts == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('checkin_confirm_help_title')),
        content: Text(
          context.tr(
            'checkin_confirm_help_body',
            namedArgs: {
              'category': selection.$1,
              'contacts': contacts
                  .map((contact) => contact.name.isEmpty ? contact.role : contact.name)
                  .join(', '),
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('send_sms')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _sendCheckIn(
      contacts: contacts,
      status: context.tr(
        urgent ? 'checkin_status_urgent' : 'checkin_status_help',
      ),
      category: selection.$1,
    );
  }

  Future<List<({String name, String role, String number})>?>
  _chooseCheckInRecipients({
    required List<({String name, String role, String number})> allContacts,
    required List<({String name, String role, String number})> defaults,
    required String title,
  }) async {
    if (allContacts.isEmpty) {
      _showCheckInMessage(context.tr('checkin_add_contact_first'));
      return null;
    }

    final selectedNumbers = defaults.map((contact) => contact.number).toSet();
    return showDialog<List<({String name, String role, String number})>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final contact in allContacts)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: selectedNumbers.contains(contact.number),
                  title: Text(
                    contact.name.isEmpty ? contact.role : contact.name,
                  ),
                  subtitle: Text(
                    '${contact.role} · ${contact.number}',
                  ),
                  onChanged: (selected) => setDialogState(() {
                    if (selected == true) {
                      selectedNumbers.add(contact.number);
                    } else {
                      selectedNumbers.remove(contact.number);
                    }
                  }),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              onPressed: selectedNumbers.isEmpty
                  ? null
                  : () => Navigator.pop(
                      dialogContext,
                      allContacts
                          .where(
                            (contact) =>
                                selectedNumbers.contains(contact.number),
                          )
                          .toList(),
                    ),
              child: Text(
                context.tr(
                  'continue_count',
                  namedArgs: {'count': '${selectedNumbers.length}'},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<({String name, String role, String number})> _trustedContacts(
    UserProfile profile, {
    bool includeMedical = true,
  }) {
    final contacts = <({String name, String role, String number})>[
      (
        name: profile.emContactName,
        role: context.tr('role_primary_contact'),
        number: profile.emContactNumber,
      ),
      (
        name: profile.secondContactName,
        role: _localizedContactRole(
          profile.secondContactLabel,
          'Family / Teacher',
          'role_family_teacher',
        ),
        number: profile.secondContactNumber,
      ),
      if (includeMedical)
        (
          name: profile.medicalContactName,
          role: _localizedContactRole(
            profile.medicalContactLabel,
            'Doctor / Nurse / Hospital',
            'role_medical_contact',
          ),
          number: profile.medicalContactNumber,
        ),
    ];
    final seen = <String>{};
    return contacts.where((contact) {
      final number = contact.number.trim();
      if (number.isEmpty || number.contains('X')) return false;
      return seen.add(number.replaceAll(RegExp(r'[^0-9+]'), ''));
    }).toList();
  }

  String _localizedContactRole(String label, String defaultLabel, String key) {
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty ||
        trimmedLabel.toLowerCase() == defaultLabel.toLowerCase()) {
      return context.tr(key);
    }
    return trimmedLabel;
  }

  Future<void> _sendCheckIn({
    required List<({String name, String role, String number})> contacts,
    required String status,
    required String category,
  }) async {
    if (contacts.isEmpty) {
      _showCheckInMessage(context.tr('checkin_add_contact_first'));
      return;
    }

    CachedLocation? location = ref.read(emergencyProvider).currentLocation;
    location ??= await LocationService.getCachedLocation();
    if (location == null) {
      try {
        if (await LocationService.ensureLocationPermission()) {
          location = await LocationService.getFullLocation();
        }
      } catch (_) {
        location = null;
      }
    }
    final timestamp = DateTime.now().toLocal().toIso8601String();
    final coords = location == null
        ? context.tr('unknown_location')
        : '${location.latitude.toStringAsFixed(4)},${location.longitude.toStringAsFixed(4)}';
    final locationUrl = location == null
        ? context.tr('unknown_location')
        : 'https://maps.google.com/?q=$coords';
    final message = context.tr(
      'checkin_sms_template',
      namedArgs: {
        'status': status,
        'risk': category,
        'time': timestamp,
        'location': locationUrl,
      },
    );

    var sentCount = 0;
    var openedCount = 0;
    ref.read(emergencyProvider.notifier).setSendingSos(true);
    try {
      for (final contact in contacts) {
        final result = await SmsService.sendSms(
          phone: contact.number,
          message: message,
        );
        if (result.sent) sentCount++;
        if (result.status == 'sms_app_opened') openedCount++;
      }
      final summary = sentCount > 0
          ? context.tr(
              'checkin_sms_sent_count',
              namedArgs: {
                'sent': '$sentCount',
                'total': '${contacts.length}',
              },
            )
          : openedCount > 0
          ? context.tr('checkin_sms_opened')
          : context.tr('checkin_sms_failed');
      if (sentCount > 0 || openedCount > 0) {
        await HapticsService.strongConfirmation();
      }
      _showCheckInMessage(summary);
    } catch (_) {
      _showCheckInMessage(context.tr('checkin_send_error'));
    } finally {
      ref.read(emergencyProvider.notifier).setSendingSos(false);
    }
  }

  void _showCheckInMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emergencyState = ref.watch(emergencyProvider);
    final profileAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('em_title'),
          style: AppTextStyles.heading2.copyWith(color: AppColors.red),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                context.tr('active'),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            _buildSafeCheckInCard(profileAsync, emergencyState.isSendingSos),

            SizedBox(height: 24.h),

            // Status / Confirmation Card
            emergencyState.sosSent
                ? _buildSentConfirmationCard()
                : _buildReadyCard(emergencyState),

            SizedBox(height: 24.h),
            _buildPulsingSosButton(context, ref),

            SizedBox(height: 32.h),

            // GPS Info Row with Status Indicator
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Status Indicator
                  if (emergencyState.isLocationLoading)
                    SizedBox(
                      width: 24.sp,
                      height: 24.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFFFA500)),
                      ),
                    )
                  else if (emergencyState.currentLocation != null)
                    Icon(
                      Icons.location_on,
                      color: emergencyState.isLocationAccurate
                          ? Color(0xFF4CAF50) // 🟢 Green for accurate
                          : Color(0xFFFFA500), // 🟡 Orange for approximate
                      size: 24.sp,
                    )
                  else
                    Icon(
                      Icons.location_off,
                      color: Color(0xFFFF5252), // 🔴 Red for unavailable
                      size: 24.sp,
                    ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              context.tr('gps_lbl'),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Status badge
                            if (emergencyState.isLocationLoading)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(
                                    0xFFFFA500,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text('📡', style: AppTextStyles.caption),
                              )
                            else if (emergencyState.currentLocation != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: emergencyState.isLocationAccurate
                                      ? Color(0xFF4CAF50).withValues(alpha: 0.2)
                                      : Color(
                                          0xFFFFA500,
                                        ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  emergencyState.isLocationAccurate
                                      ? '🟢'
                                      : '🟡',
                                  style: AppTextStyles.caption,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        // Show location name if available, otherwise coordinates
                        if (emergencyState.currentLocation != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (emergencyState.currentLocation!.address !=
                                  null)
                                Text(
                                  emergencyState.currentLocation!.address!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (emergencyState.currentLocation!.address !=
                                  null)
                                SizedBox(height: 4.h),
                              Text(
                                '${emergencyState.currentLocation!.latitude.toStringAsFixed(4)}, ${emergencyState.currentLocation!.longitude.toStringAsFixed(4)}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                context.tr(
                                  'location_accuracy',
                                  namedArgs: {
                                    'meters': emergencyState.currentLocation!.accuracy.toStringAsFixed(0),
                                  },
                                ),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            emergencyState.isLocationLoading
                                ? context.tr('location_getting')
                                : AppConstants.defaultLocationText,
                            style: AppTextStyles.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Emergency Contacts
            Text(
              context.tr('contacts'),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 16.h),

            OutlinedButton.icon(
              onPressed: () => context.go(AppConstants.routeTrustedCircle),
              icon: const Icon(Icons.group_outlined),
              label: Text(context.tr('manage_trusted_circle')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.teal,
                side: const BorderSide(color: AppColors.teal),
                minimumSize: Size(double.infinity, 48.h),
              ),
            ),
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              onPressed: () => context.go(AppConstants.routeNearbyPlaces),
              icon: const Icon(Icons.map_outlined),
              label: Text(context.tr('nearby_support_places')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.teal,
                side: const BorderSide(color: AppColors.teal),
                minimumSize: Size(double.infinity, 48.h),
              ),
            ),
            SizedBox(height: 12.h),

            profileAsync.when(
              data: (profile) => Column(
                children: [
                  ContactRow(
                    name: profile.emContactName,
                    number: profile.emContactNumber,
                    onCall: () => _makeCall(profile.emContactNumber),
                  ),
                  if (profile.secondContactName.isNotEmpty ||
                      profile.secondContactNumber.isNotEmpty)
                    ContactRow(
                      name: profile.secondContactLabel.isNotEmpty
                          ? '${_localizedContactRole(
                              profile.secondContactLabel,
                              'Family / Teacher',
                              'role_family_teacher',
                            )}: ${profile.secondContactName}'
                          : profile.secondContactName,
                      number: profile.secondContactNumber,
                      onCall: () => _makeCall(profile.secondContactNumber),
                    ),
                  if (profile.medicalContactName.isNotEmpty ||
                      profile.medicalContactNumber.isNotEmpty)
                    ContactRow(
                      name: profile.medicalContactLabel.isNotEmpty
                          ? '${_localizedContactRole(
                              profile.medicalContactLabel,
                              'Doctor / Nurse / Hospital',
                              'role_medical_contact',
                            )}: ${profile.medicalContactName}'
                          : profile.medicalContactName,
                      number: profile.medicalContactNumber,
                      onCall: () => _makeCall(profile.medicalContactNumber),
                    ),
                  ContactRow(
                     name: context.tr('role_police'),
                    number: AppConstants.policeNumber,
                    onCall: () => _makeCall(AppConstants.policeNumber),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text(context.tr('emergency_profile_error')),
            ),

            SizedBox(height: 32.h),

            // Auto SMS Preview
            Text(
              context.tr('auto_sms_lbl'),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 12.h),

            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Color(0xFF3D0000),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('sos_sms_intro'),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.tr(
                      'location_preview_address',
                      namedArgs: {
                        'location': emergencyState.currentLocation?.address?.isNotEmpty == true
                            ? emergencyState.currentLocation!.address!
                            : context.tr('unknown_location'),
                      },
                    ),
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    emergencyState.currentLocation != null
                        ? context.tr(
                            'location_preview_gps',
                            namedArgs: {
                              'coordinates': '${emergencyState.currentLocation!.latitude.toStringAsFixed(4)}, ${emergencyState.currentLocation!.longitude.toStringAsFixed(4)}',
                            },
                          )
                        : context.tr('location_preview_gps_unknown'),
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: 8.h),
                  Text('-SilentHelp', style: AppTextStyles.caption),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Privacy Notice
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                context.tr('emergency_location_privacy'),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ── Status cards ─────────────────────────────────────────────────────────

  Widget _buildReadyCard(EmergencyState state) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.teal, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.teal, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('sos_ready_to_send'),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  state.currentLocation != null
                      ? '${context.tr('location_ready')} (${state.isLocationAccurate ? context.tr('location_accurate') : context.tr('location_approximate')})'
                      : context.tr('location_getting'),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentConfirmationCard() {
    final timeStr = _sentAt != null
        ? '${_sentAt!.hour.toString().padLeft(2, '0')}:'
              '${_sentAt!.minute.toString().padLeft(2, '0')}:'
              '${_sentAt!.second.toString().padLeft(2, '0')}'
        : '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4D2E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.send, color: const Color(0xFF4CAF50), size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('sos_sent_successfully'),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (timeStr.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    context.tr(
                      'sos_dispatched_at',
                      namedArgs: {'time': timeStr},
                    ),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPulsingSosButton(BuildContext context, WidgetRef ref) {
    final completionAsync = ref.watch(profileCompletionProvider);

    return completionAsync.when(
      data: (completion) {
        final isEnabled = completion.isEmergencyContactComplete;

        return GestureDetector(
          onTap: isEnabled
              ? () {
                  _sendSOS(context, ref);
                }
              : () {
                  // Show message prompting to add emergency contact
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('complete_required')),
                      duration: const Duration(seconds: 3),
                      backgroundColor: AppColors.red,
                      action: SnackBarAction(
                        label: context.tr('edit_profile'),
                        textColor: Colors.white,
                        onPressed: () {
                          context.go(AppConstants.routeProfile);
                        },
                      ),
                    ),
                  );
                  HapticsService.lightImpact();
                },
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: isEnabled ? 1.03 : 1.0).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(30.h),
              decoration: BoxDecoration(
                color: (isEnabled ? AppColors.red : AppColors.textMuted)
                    .withValues(alpha: isEnabled ? 1.0 : 0.5),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  Text(
                    context.tr('send_sos'),
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    isEnabled
                        ? context.tr('send_sos_sub')
                        : context.tr('complete_required'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(30.h),
          decoration: BoxDecoration(
            color: AppColors.textMuted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              Text(
                context.tr('send_sos'),
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      error: (_, __) => GestureDetector(
        onTap: () {
          _sendSOS(context, ref);
        },
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.03).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(30.h),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Text(
                  context.tr('send_sos'),
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  context.tr('send_sos_sub'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendSOS(BuildContext context, WidgetRef ref) async {
    // Initial vibration feedback when SOS button is pressed
    await HapticsService.strongConfirmation();

    final profileAsync = ref.read(settingsProvider);
    final profile = await profileAsync.valueOrNull;

    if (profile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('emergency_profile_loading')),
          ),
        );
      }
      return;
    }

    final recipient = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('sos_choose_recipient')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(context.tr('role_primary_contact')),
                subtitle: Text(
                  profile.emContactName.isNotEmpty
                      ? profile.emContactName
                      : context.tr('role_primary_contact'),
                ),
                onTap: () => Navigator.of(dialogContext).pop('primary'),
              ),
              if (profile.secondContactName.isNotEmpty ||
                  profile.secondContactNumber.isNotEmpty)
                ListTile(
                  title: Text(context.tr('role_family_teacher')),
                  subtitle: Text(
                    profile.secondContactName.isNotEmpty
                        ? profile.secondContactName
                        : _localizedContactRole(
                            profile.secondContactLabel,
                            'Family / Teacher',
                            'role_family_teacher',
                          ),
                  ),
                  onTap: () => Navigator.of(dialogContext).pop('family'),
                ),
              if (profile.medicalContactName.isNotEmpty ||
                  profile.medicalContactNumber.isNotEmpty)
                ListTile(
                  title: Text(context.tr('role_medical_contact')),
                  subtitle: Text(
                    profile.medicalContactName.isNotEmpty
                        ? profile.medicalContactName
                        : _localizedContactRole(
                            profile.medicalContactLabel,
                            'Doctor / Nurse / Hospital',
                            'role_medical_contact',
                          ),
                  ),
                  onTap: () => Navigator.of(dialogContext).pop('medical'),
                ),
              ListTile(
                title: Text(context.tr('role_police')),
                subtitle: const Text('+256 999'),
                onTap: () => Navigator.of(dialogContext).pop('police'),
              ),
            ],
          ),
        );
      },
    );

    if (recipient == null) {
      return;
    }

    ref.read(emergencyProvider.notifier).setSendingSos(true);

    try {
      final emergencyNotifier = ref.read(emergencyProvider.notifier);
      String emContactNumber = '+256 700 123 456';
      String recipientName = context.tr('role_primary_contact');

      switch (recipient) {
        case 'primary':
          emContactNumber = profile.emContactNumber;
          recipientName = profile.emContactName.isNotEmpty
              ? profile.emContactName
              : context.tr('role_primary_contact');
          break;
        case 'family':
          emContactNumber = profile.secondContactNumber;
          recipientName = _localizedContactRole(
            profile.secondContactLabel,
            'Family / Teacher',
            'role_family_teacher',
          );
          break;
        case 'medical':
          emContactNumber = profile.medicalContactNumber;
          recipientName = _localizedContactRole(
            profile.medicalContactLabel,
            'Doctor / Nurse / Hospital',
            'role_medical_contact',
          );
          break;
        case 'police':
          emContactNumber = AppConstants.policeNumber;
          recipientName = context.tr('role_police');
          break;
        default:
          emContactNumber = profile.emContactNumber;
          recipientName = profile.emContactName.isNotEmpty
              ? profile.emContactName
              : context.tr('role_primary_contact');
      }

      if (emContactNumber.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr(
                  'sos_missing_contact_number',
                  namedArgs: {'contact': recipientName},
                ),
              ),
              backgroundColor: AppColors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Strategy: Send immediately with cached location, then improve in background
      CachedLocation? currentLocation = ref
          .read(emergencyProvider)
          .currentLocation;

      // If no cached location, try to fetch it now
      if (currentLocation == null) {
        currentLocation = await LocationService.getCachedLocation();
        if (currentLocation != null) {
          emergencyNotifier.loadCachedLocation();
        } else {
          // Fallback: Quick location fetch
          currentLocation = await LocationService.getFullLocation(
            highAccuracy: false,
          );
          if (currentLocation != null) {
            emergencyNotifier.setPosition(
              Position(
                latitude: currentLocation.latitude,
                longitude: currentLocation.longitude,
                timestamp: DateTime.now(),
                accuracy: currentLocation.accuracy,
                altitude: 0,
                altitudeAccuracy: 0,
                heading: 0,
                headingAccuracy: 0,
                speed: 0,
                speedAccuracy: 0,
              ),
            );
          }
        }
      }

      // Prepare location text and coordinates
      final address = currentLocation?.address?.isNotEmpty == true
          ? currentLocation!.address!
          : context.tr('unknown_location');
      final coordinates = currentLocation != null
          ? '${currentLocation.latitude.toStringAsFixed(4)}, ${currentLocation.longitude.toStringAsFixed(4)}'
          : context.tr('unknown_location');

      // Log: SOS message prepared
      await ref
          .read(sosLogProvider.notifier)
          .addLogEntry(
            SOSLogEntry(
              timestamp: DateTime.now(),
              message: 'To: $emContactNumber | Location: $address',
              status: 'prepared',
            ),
          );

      // IMMEDIATE SOS SEND
      final sendResult = await _sendSmsMessage(
        context,
        emContactNumber,
        address,
        coordinates,
      );

      // Log: actual SMS send/delivery outcome
      await ref
          .read(sosLogProvider.notifier)
          .addLogEntry(
            SOSLogEntry(
              timestamp: DateTime.now(),
              message: 'To: $emContactNumber | Location: $address',
              status: sendResult.status,
            ),
          );

      final bool wasSent = sendResult.sent;
      if (wasSent) {
        setState(() => _sentAt = DateTime.now());
        ref.read(emergencyProvider.notifier).setSosSent(true);
      }

      if (sendResult.deliveryConfirmed) {
        await HapticsService.strongConfirmation();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('sos_delivery_confirmed')),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (sendResult.sent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('sos_delivery_unconfirmed')),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (sendResult.status == 'sms_app_opened') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('sos_sms_app_opened')),
              backgroundColor: const Color(0xFFFFA000),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      // Location continues refreshing in the background for UI display only.
      // No further SMS is sent — exactly one SOS message per tap.
    } catch (_) {
      // Error vibration
      await HapticsService.selectionClick();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('sos_send_error')),
            backgroundColor: AppColors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      ref.read(emergencyProvider.notifier).setSendingSos(false);
    }
  }

  /// Build human-readable location text from CachedLocation (includes both address and coordinates)
  Future<SmsSendResult> _sendSmsMessage(
    BuildContext context,
    String phoneNumber,
    String address,
    String coordinates,
  ) async {
    // Keep the address compact; localized text may require multipart SMS.
    final safeAddress = address.length > 60
        ? '${address.substring(0, 57)}...'
        : address;

    final message =
        context.tr(
          'sos_sms_template',
          namedArgs: {
            'location': safeAddress,
            'coordinates': coordinates,
          },
        );

    try {
      return await SmsService.sendSms(
        phone: phoneNumber.isNotEmpty ? phoneNumber : '',
        message: message,
      );
    } on SmsPermissionException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('sos_sms_permission_error')),
            backgroundColor: AppColors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('SMS send error: $e');
      rethrow;
    }
  }

  Future<void> _makeCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
