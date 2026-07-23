import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
        title: Text(context.tr('id_title'), style: AppTextStyles.heading2),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading profile')),
        data: (profile) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Physical-style ID Card ─────────────────────────────
              _IdCard(profile: profile),

              SizedBox(height: 32.h),

              // ── Emergency Contacts ─────────────────────────────────
              _SectionHeader(
                icon: Icons.emergency_rounded,
                label: context.tr('contacts'),
                color: AppColors.red,
              ),
              SizedBox(height: 12.h),

              _ContactCard(
                label: 'Primary Emergency',
                name: profile.emContactName,
                number: profile.emContactNumber,
                icon: Icons.emergency_rounded,
                color: AppColors.red,
              ),

              // Second contact removed from this list to avoid duplication

              if (profile.medicalContactName.isNotEmpty ||
                  profile.medicalContactNumber.isNotEmpty)
                _ContactCard(
                  label: profile.medicalContactLabel.isNotEmpty
                      ? profile.medicalContactLabel
                      : 'Doctor / Nurse / Hospital',
                  name: profile.medicalContactName,
                  number: profile.medicalContactNumber,
                  icon: Icons.local_hospital_rounded,
                  color: AppColors.blue,
                ),

              SizedBox(height: 32.h),

              // ── QR Code ────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.qr_code_2_rounded,
                label: context.tr('scan_lbl'),
                color: AppColors.teal,
              ),
              SizedBox(height: 12.h),
              _QrSection(profile: profile),

              SizedBox(height: 20.h),

              // ── Share via SMS ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  icon: Icon(Icons.share_rounded,
                      color: AppColors.background, size: 20.sp),
                  label: Text(
                    context.tr('share_sms'),
                    style: AppTextStyles.buttonMedium
                        .copyWith(color: AppColors.background),
                  ),
                  onPressed: () => _shareViaSMS(context, profile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareViaSMS(
      BuildContext context, UserProfile profile) async {
    final message =
      'PROFILE CARD — ${profile.name.toUpperCase()}\n\n'
      'I use Ugandan Sign Language (UgSL)\n'
      'Please write or text me.\n\n'
      'Emergency Contact: ${profile.emContactName} — ${profile.emContactNumber}\n'
      '${profile.secondContactName.isNotEmpty ? '${profile.secondContactLabel}: ${profile.secondContactName} — ${profile.secondContactNumber}\n' : ''}'
      '${profile.medicalContactName.isNotEmpty ? '${profile.medicalContactLabel}: ${profile.medicalContactName} — ${profile.medicalContactNumber}\n' : ''}'
      'Phone: ${profile.phone}\n'
      '\n-SilentHelp';

    final uri = Uri(scheme: 'sms', queryParameters: {'body': message});
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not open SMS';
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open SMS')),
      );
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ID Card widget
// ════════════════════════════════════════════════════════════════════════════

class _IdCard extends StatelessWidget {
  const _IdCard({required this.profile});
  final UserProfile profile;

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _idNumber(String name) {
    final code = name.hashCode.abs().toString();
    return 'SH-${code.substring(0, code.length.clamp(0, 6)).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(profile.name);
    final idNum = _idNumber(profile.name);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: const BoxDecoration(color: AppColors.teal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SILENTHELP',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.background,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'MEDICAL IDENTIFICATION',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.background.withValues(alpha: 0.75),
                          letterSpacing: 1,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hearing_disabled_rounded,
                          color: AppColors.background,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          profile.condition.isEmpty
                              ? 'DEAF'
                              : profile.condition.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Main body ─────────────────────────────────────────────
            Container(
              color: AppColors.card,
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + initials avatar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar circle
                      Container(
                        width: 68.w,
                        height: 68.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tealDark,
                          border: Border.all(
                              color: AppColors.teal, width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name.toUpperCase(),
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 10.h),
                            // Phone badge (simplified: removed blood type to reduce clutter)
                            _Badge(
                              label: profile.phone.isEmpty ? '—' : profile.phone,
                              sublabel: 'PHONE',
                              color: AppColors.teal,
                              isWide: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Subtle divider
                  Divider(color: AppColors.border, height: 1),

                  SizedBox(height: 18.h),

                  // Info rows
                  if (profile.emContactName.isNotEmpty) ...[
                    _InfoRow(
                      icon: Icons.contact_emergency_rounded,
                      label: 'Emergency Contact',
                      value:
                          '${profile.emContactName}  ${profile.emContactNumber}',
                      iconColor: AppColors.red,
                    ),
                    SizedBox(height: 12.h),
                  ],
                  // medicalNote removed (information conveyed in communication strip)
                ],
              ),
            ),

            // ── Communication strip ────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              color: AppColors.teal.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.sign_language_rounded,
                    color: AppColors.teal,
                    size: 22.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I use Ugandan Sign Language (UgSL)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Please write, text, or use simple gestures',
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

            // ── Footer ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 20.w, vertical: 10.h),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    idNum,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                      fontSize: 10.sp,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded,
                          color: AppColors.teal, size: 12.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'SilentHelp · ${DateTime.now().year}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Supporting card widgets
// ════════════════════════════════════════════════════════════════════════════

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.sublabel,
    required this.color,
    this.isWide = false,
  });
  final String label;
  final String sublabel;
  final Color color;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 10.w : 8.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sublabel,
            style: AppTextStyles.caption.copyWith(
              color: color.withValues(alpha: 0.8),
              fontSize: 8.sp,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: isWide ? 11.sp : 13.sp,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: iconColor, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value.isEmpty ? '—' : value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: value.isEmpty
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Section header
// ════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Emergency contact card
// ════════════════════════════════════════════════════════════════════════════

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.label,
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });
  final String label;
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  Future<void> _call() async {
    if (number.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final hasData = name.isNotEmpty || number.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          // Name + label + number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.sp,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  name.isNotEmpty ? name : '—',
                  style: AppTextStyles.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                if (number.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    number,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Call button
          if (hasData && number.isNotEmpty)
            GestureDetector(
              onTap: _call,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.call_rounded, color: color, size: 18.sp),
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// QR code section
// ════════════════════════════════════════════════════════════════════════════

class _QrSection extends StatelessWidget {
  const _QrSection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({
      'name': profile.name,
      'phone': profile.phone,
      'condition': profile.condition,
      'emContact': profile.emContactName,
      'emPhone': profile.emContactNumber,
    });

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCAN QR CODE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Share your full profile with first responders',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Icon(Icons.qr_code_2_rounded,
                  color: AppColors.teal, size: 32.sp),
            ],
          ),

          SizedBox(height: 20.h),

          // QR on white card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: PrettyQrView.data(
              data: qrData,
              decoration: const PrettyQrDecoration(),
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            'Point a camera at this code to read the card',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
