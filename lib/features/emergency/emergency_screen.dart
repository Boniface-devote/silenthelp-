import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/language_bar.dart';
import '../../shared/widgets/contact_row.dart';
import 'emergency_provider.dart';
import '../settings/settings_provider.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
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
            // Language Bar
            LanguageBar(),

            SizedBox(height: 24.h),

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

            // SOS Button with pulse
            _buildPulsingSosButton(context, ref),

            SizedBox(height: 32.h),

            // GPS Info Row
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Color(0xFF4CAF50),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('gps_lbl'),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          emergencyState.currentPosition != null
                              ? '${emergencyState.currentPosition!.latitude.toStringAsFixed(4)}, ${emergencyState.currentPosition!.longitude.toStringAsFixed(4)}'
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
                  // Primary Contact
                  ContactRow(
                    name: profile.emContactName,
                    number: profile.emContactNumber,
                    onCall: () => _makeCall(profile.emContactNumber),
                  ),
                  // Police
                  ContactRow(
                    name: 'Police',
                    number: AppConstants.policeNumber,
                    onCall: () =>
                        _makeCall(AppConstants.policeNumber),
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
                    'EMERGENCY: I am deaf and need immediate help.',
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'My location: ${emergencyState.currentPosition != null ? '${emergencyState.currentPosition!.latitude.toStringAsFixed(4)}, ${emergencyState.currentPosition!.longitude.toStringAsFixed(4)}' : AppConstants.defaultLocationText}',
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '— SilentHelp',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingSosButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
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
    );
  }

  Future<void> _sendSOS(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();

    ref.read(emergencyProvider.notifier).setSendingSos(true);

    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => Position(
          latitude: 0.3,
          longitude: 32.6,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
      );

      ref.read(emergencyProvider.notifier).setPosition(position);

      // Get emergency contact
      final profileAsync = ref.read(settingsProvider);
      String emContactNumber = '+256 700 123 456';
      
      profileAsync.whenData((profile) {
        emContactNumber = profile.emContactNumber;
      });

      // Compose message
      final locationText =
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      final message =
          'EMERGENCY: I am deaf and need immediate help. My location: $locationText — SilentHelp';

      // Try to send SMS
      try {
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: emContactNumber,
          queryParameters: {'body': message},
        );

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
          ref.read(emergencyProvider.notifier).setSosSent(true);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('sos_sent')),
                backgroundColor: AppColors.red,
              ),
            );
          }
        } else {
          throw 'Could not launch SMS';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context
                  .tr('sos_failed')
                  .replaceFirst('{num}', emContactNumber)),
              backgroundColor: AppColors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      ref.read(emergencyProvider.notifier).setSendingSos(false);
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
