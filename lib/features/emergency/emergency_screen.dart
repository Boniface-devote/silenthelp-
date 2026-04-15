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
import '../../core/services/location_service.dart';
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
                                  color: Color(0xFFFFA500).withOpacity(0.2),
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
                                      ? Color(0xFF4CAF50).withOpacity(0.2)
                                      : Color(0xFFFFA500).withOpacity(0.2),
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
                    'My location: ${emergencyState.currentLocation != null ? (emergencyState.currentLocation!.address?.isNotEmpty == true ? emergencyState.currentLocation!.address! : '${emergencyState.currentLocation!.latitude.toStringAsFixed(4)}, ${emergencyState.currentLocation!.longitude.toStringAsFixed(4)}') : AppConstants.defaultLocationText}',
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
    // Initial vibration feedback when SOS button is pressed
    HapticFeedback.heavyImpact();

    ref.read(emergencyProvider.notifier).setSendingSos(true);

    try {
      final emergencyNotifier = ref.read(emergencyProvider.notifier);
      final profileAsync = ref.read(settingsProvider);
      String emContactNumber = '+256 700 123 456';

      // Get emergency contact
      profileAsync.whenData((profile) {
        emContactNumber = profile.emContactNumber;
      });

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

      // Prepare location text
      final locationText = _buildLocationText(currentLocation);

      // IMMEDIATE SOS SEND
      await _sendSmsMessage(
        context,
        emContactNumber,
        locationText,
        emergencyNotifier,
      );

      // SUCCESS: Send SOS was successful
      ref.read(emergencyProvider.notifier).setSosSent(true);

      // Success vibration pattern: rapid pulses
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('sos_sent')),
            backgroundColor: AppColors.red,
          ),
        );
      }

      // BACKGROUND: Try to get better location and send updated SOS
      _improveLocationInBackground(context, ref, emContactNumber, currentLocation);
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

  /// Build human-readable location text from CachedLocation
  String _buildLocationText(CachedLocation? location) {
    if (location == null) {
      return AppConstants.defaultLocationText;
    }
    if (location.address?.isNotEmpty == true) {
      return location.address!;
    }
    return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
  }

  /// Send SMS with location information
  Future<void> _sendSmsMessage(
    BuildContext context,
    String phoneNumber,
    String locationText,
    EmergencyNotifier notifier,
  ) async {
    final message =
        'EMERGENCY: I am deaf and need immediate help. My location: $locationText — SilentHelp';

    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw 'Could not launch SMS';
      }
    } catch (e) {
      print('SMS send error: $e');
      rethrow;
    }
  }

  /// Background task: Try to get better accuracy location and send updated SOS
  void _improveLocationInBackground(
    BuildContext context,
    WidgetRef ref,
    String emContactNumber,
    CachedLocation? originalLocation,
  ) {
    // Run in background without blocking UI
    Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      try {
        final betterLocation =
            await LocationService.getHighAccuracyLocation();

        if (betterLocation != null &&
            betterLocation.accuracy <
                (originalLocation?.accuracy ?? 1000)) {
          // We got a better location, update the cache and send updated SOS
          final cachedLocation = CachedLocation(
            latitude: betterLocation.latitude,
            longitude: betterLocation.longitude,
            accuracy: betterLocation.accuracy,
            address: originalLocation?.address,
            timestamp: DateTime.now(),
          );

          // Update UI
          ref
              .read(emergencyProvider.notifier)
              .setPosition(Position(
                latitude: betterLocation.latitude,
                longitude: betterLocation.longitude,
                timestamp: DateTime.now(),
                accuracy: betterLocation.accuracy,
                altitude: 0,
                altitudeAccuracy: 0,
                heading: 0,
                headingAccuracy: 0,
                speed: 0,
                speedAccuracy: 0,
              ));

          ref
              .read(emergencyProvider.notifier)
              .setLocationLoading(false);

          // Try to send updated SOS
          final updatedLocationText = _buildLocationText(cachedLocation);
          await _sendSmsMessage(
            context,
            emContactNumber,
            updatedLocationText,
            ref.read(emergencyProvider.notifier),
          );

          print(
              'Background: Sent updated SOS with better location (${betterLocation.accuracy.toStringAsFixed(0)}m)');
        }
      } catch (e) {
        print('Background location improvement failed: $e');
        // Silently fail - don't disturb user
      }
    });
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
