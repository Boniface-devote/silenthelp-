import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/contact_row.dart';
import '../../core/services/location_service.dart';
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
  DateTime? _sentAt;   // set when SOS is dispatched

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
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFA500).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '📡',
                                  style: AppTextStyles.caption,
                                ),
                              )
                            else if (emergencyState.currentLocation != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: emergencyState.isLocationAccurate
                                      ? Color(0xFF4CAF50).withValues(alpha: 0.2)
                                      : Color(0xFFFFA500).withValues(alpha: 0.2),
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
                                'Accuracy: ${emergencyState.currentLocation!.accuracy.toStringAsFixed(0)}m',
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
                                ? '📡 Getting your location...'
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

            profileAsync.when(
              data: (profile) => Column(
                children: [
                  ContactRow(
                    name: profile.emContactName,
                    number: profile.emContactNumber,
                    onCall: () => _makeCall(profile.emContactNumber),
                  ),
                  if (profile.secondContactName.isNotEmpty || profile.secondContactNumber.isNotEmpty)
                    ContactRow(
                      name: profile.secondContactLabel.isNotEmpty
                          ? '${profile.secondContactLabel}: ${profile.secondContactName}'
                          : profile.secondContactName,
                      number: profile.secondContactNumber,
                      onCall: () => _makeCall(profile.secondContactNumber),
                    ),
                  if (profile.medicalContactName.isNotEmpty || profile.medicalContactNumber.isNotEmpty)
                    ContactRow(
                      name: profile.medicalContactLabel.isNotEmpty
                          ? '${profile.medicalContactLabel}: ${profile.medicalContactName}'
                          : profile.medicalContactName,
                      number: profile.medicalContactNumber,
                      onCall: () => _makeCall(profile.medicalContactNumber),
                    ),
                  ContactRow(
                    name: 'Police',
                    number: AppConstants.policeNumber,
                    onCall: () => _makeCall(AppConstants.policeNumber),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error loading profile'),
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
                    'SOS! I am Deaf (UgSL). Need help!',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Loc: ${emergencyState.currentLocation?.address?.isNotEmpty == true ? emergencyState.currentLocation!.address! : 'Unknown location'}',
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    emergencyState.currentLocation != null
                        ? 'GPS: ${emergencyState.currentLocation!.latitude.toStringAsFixed(4)}, ${emergencyState.currentLocation!.longitude.toStringAsFixed(4)}'
                        : 'GPS: Unknown',
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '-SilentHelp',
                    style: AppTextStyles.caption,
                  ),
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
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Text(
                '🔒 Your location is only used during emergencies. We do not track you continuously.',
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
                  'Ready to send emergency alert',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  state.currentLocation != null
                      ? '📍 Location ready '
                          '${state.isLocationAccurate ? '🟢 (Accurate)' : '🟡 (Approximate)'}'
                      : '📡 Getting location...',
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
                  '✅  SOS sent successfully',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (timeStr.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Dispatched at $timeStr',
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
                      content: Text(
                        context.tr('complete_required'),
                      ),
                      duration: const Duration(seconds: 3),
                      backgroundColor: AppColors.red,
                      action: SnackBarAction(
                        label: 'Go to Settings',
                        textColor: Colors.white,
                        onPressed: () {
                          context.go(AppConstants.routeSettings);
                        },
                      ),
                    ),
                  );
                  HapticFeedback.lightImpact();
                },
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: isEnabled ? 1.03 : 1.0).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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
    HapticFeedback.heavyImpact();

    final profileAsync = ref.read(settingsProvider);
    final profile = await profileAsync.valueOrNull;

    if (profile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile is still loading. Please try again.')),
        );
      }
      return;
    }

    final recipient = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Send SOS to'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Primary emergency contact'),
                subtitle: Text(profile.emContactName.isNotEmpty ? profile.emContactName : 'Primary contact'),
                onTap: () => Navigator.of(dialogContext).pop('primary'),
              ),
              if (profile.secondContactName.isNotEmpty || profile.secondContactNumber.isNotEmpty)
                ListTile(
                  title: const Text('Family / teacher'),
                  subtitle: Text(profile.secondContactName.isNotEmpty ? profile.secondContactName : 'Family / teacher'),
                  onTap: () => Navigator.of(dialogContext).pop('family'),
                ),
              if (profile.medicalContactName.isNotEmpty || profile.medicalContactNumber.isNotEmpty)
                ListTile(
                  title: const Text('Doctor / nurse / hospital'),
                  subtitle: Text(profile.medicalContactName.isNotEmpty ? profile.medicalContactName : 'Medical contact'),
                  onTap: () => Navigator.of(dialogContext).pop('medical'),
                ),
              ListTile(
                title: const Text('Police'),
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
      String recipientName = 'Primary contact';

      switch (recipient) {
        case 'primary':
          emContactNumber = profile.emContactNumber;
          recipientName = profile.emContactName.isNotEmpty ? profile.emContactName : 'Primary contact';
          break;
        case 'family':
          emContactNumber = profile.secondContactNumber;
          recipientName = profile.secondContactLabel.isNotEmpty ? profile.secondContactLabel : 'Family / teacher';
          break;
        case 'medical':
          emContactNumber = profile.medicalContactNumber;
          recipientName = profile.medicalContactLabel.isNotEmpty ? profile.medicalContactLabel : 'Doctor / nurse / hospital';
          break;
        case 'police':
          emContactNumber = AppConstants.policeNumber;
          recipientName = 'Police';
          break;
        default:
          emContactNumber = profile.emContactNumber;
          recipientName = profile.emContactName.isNotEmpty ? profile.emContactName : 'Primary contact';
      }

      if (emContactNumber.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please add a phone number for $recipientName first.'),
              backgroundColor: AppColors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Strategy: Send immediately with cached location, then improve in background
      CachedLocation? currentLocation =
          ref.read(emergencyProvider).currentLocation;

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
            emergencyNotifier.setPosition(Position(
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
            ));
          }
        }
      }

      // Prepare location text and coordinates
      final address = currentLocation?.address?.isNotEmpty == true 
          ? currentLocation!.address! 
          : 'Unknown location';
      final coordinates = currentLocation != null
          ? '${currentLocation.latitude.toStringAsFixed(4)}, ${currentLocation.longitude.toStringAsFixed(4)}'
          : 'Unknown';

      // Log: SOS message prepared
      await ref.read(sosLogProvider.notifier).addLogEntry(
            SOSLogEntry(
              timestamp: DateTime.now(),
              message: 'To: $emContactNumber | Location: $address',
              status: 'prepared',
            ),
          );

      // IMMEDIATE SOS SEND
      await _sendSmsMessage(
        context,
        emContactNumber,
        address,
        coordinates,
      );

      // Log: SOS opened in SMS app
      await ref.read(sosLogProvider.notifier).addLogEntry(
            SOSLogEntry(
              timestamp: DateTime.now(),
              message: 'To: $emContactNumber | Location: $address',
              status: 'opened_in_sms',
            ),
          );

      // SUCCESS: stamp time, update state, fire haptics
      setState(() => _sentAt = DateTime.now());
      ref.read(emergencyProvider.notifier).setSosSent(true);

      // Strong vibration feedback for SMS confirmation
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ SOS sent successfully'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Location continues refreshing in the background for UI display only.
      // No further SMS is sent — exactly one SOS message per tap.
    } catch (e) {
      // Error vibration
      HapticFeedback.selectionClick();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
  Future<void> _sendSmsMessage(
    BuildContext context,
    String phoneNumber,
    String address,
    String coordinates,
  ) async {
    // Keep the message inside a single SMS (<=160 chars, GSM-7 only).
    // Non-GSM-7 chars (e.g. the em-dash) force UCS-2 encoding which cuts the
    // per-part limit to 70 chars and caused 4 charged messages per SOS tap.
    // Use only plain ASCII and truncate the address if it is unusually long.
    final safeAddress =
        address.length > 60 ? '${address.substring(0, 57)}...' : address;

    // Max length check (all ASCII/GSM-7, ~133 chars worst case):
    //   35  "SOS! I am Deaf (UgSL). Need help!\n"
    //   65  "Loc: " + 60-char address
    //    1  "\n"
    //   20  "GPS: " + 15-char coords
    //    1  "\n"
    //   11  "-SilentHelp"
    //  ----
    //  133  < 160 single-SMS limit
    final message =
        'SOS! I am Deaf (UgSL). Need help!\n'
        'Loc: $safeAddress\n'
        'GPS: $coordinates\n'
        '-SilentHelp';

    try {
      await SmsService.sendSms(
        phone: phoneNumber.isNotEmpty ? phoneNumber : '',
        message: message,
      );
    } on SmsPermissionException catch (e) {
      // Permission permanently denied — surface to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
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
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
