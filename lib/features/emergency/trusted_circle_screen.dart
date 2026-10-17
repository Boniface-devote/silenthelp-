import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../settings/settings_provider.dart';

class TrustedCircleScreen extends ConsumerWidget {
  const TrustedCircleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Trusted Circle', style: AppTextStyles.heading2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your check-in messages go only to contacts saved in Settings. '
              'Review these people and their numbers before relying on this feature.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            SizedBox(height: 20.h),
            profileAsync.when(
              data: (profile) {
                final entries = [
                  ('Primary trusted contact', profile.emContactName, profile.emContactNumber),
                  (profile.secondContactLabel, profile.secondContactName, profile.secondContactNumber),
                  (profile.medicalContactLabel, profile.medicalContactName, profile.medicalContactNumber),
                ].where((entry) => entry.$3.trim().isNotEmpty && !entry.$3.contains('X'));

                return Column(
                  children: [
                    for (final entry in entries)
                      Card(
                        color: AppColors.card,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.teal.withValues(alpha: 0.18),
                            child: Icon(Icons.person_outline, color: AppColors.teal),
                          ),
                          title: Text(
                            entry.$2.isEmpty ? entry.$1 : entry.$2,
                            style: AppTextStyles.labelMedium,
                          ),
                          subtitle: Text('${entry.$1} · ${entry.$3}'),
                        ),
                      ),
                    if (!entries.isNotEmpty)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('No trusted contacts added yet'),
                          subtitle: Text('Add contacts in Settings to use Safe Check-In.'),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Could not load your saved contacts.'),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppConstants.routeSettings),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Add or edit contacts in Settings'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(color: AppColors.teal),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
            SizedBox(height: 28.h),
            Text('SMS escalation', style: AppTextStyles.heading2),
            SizedBox(height: 12.h),
            _EscalationTile(
              icon: Icons.check_circle_outline,
              color: AppColors.teal,
              title: 'I am safe',
              detail: 'Sends a status update to your primary and family/teacher contacts.',
            ),
            _EscalationTile(
              icon: Icons.support_agent,
              color: AppColors.yellow,
              title: 'Need support',
              detail: 'Sends the selected risk category to your primary and family/teacher contacts.',
            ),
            _EscalationTile(
              icon: Icons.emergency_outlined,
              color: AppColors.red,
              title: 'Danger now',
              detail: 'Sends the alert to every configured trusted contact, including your medical contact.',
            ),
            SizedBox(height: 12.h),
            Text(
              'Messages include the time and available location. Check-in does not confirm '
              'that a message was read or that help has arrived. If sending fails, use '
              'the Emergency SOS option or contact local services directly.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EscalationTile extends StatelessWidget {
  const _EscalationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: AppTextStyles.labelMedium),
        subtitle: Text(detail, style: AppTextStyles.caption),
      ),
    );
  }
}
