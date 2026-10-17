import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_preferences_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/language_bar.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          context.tr('settings_title'),
          style: AppTextStyles.heading2,
        ),
      ),
      body: preferences.when(
        data: (settings) => ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            Text(
              context.tr('accessibility_settings'),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 12.h),
            Card(
              color: AppColors.card,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('font_size'),
                      style: AppTextStyles.labelLarge,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      context.tr('font_size_description'),
                      style: AppTextStyles.caption,
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<double>(
                      initialValue: settings.fontScale,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(context.tr('font_size_standard')),
                        ),
                        DropdownMenuItem(
                          value: 1.15,
                          child: Text(context.tr('font_size_large')),
                        ),
                        DropdownMenuItem(
                          value: 1.3,
                          child: Text(context.tr('font_size_extra_large')),
                        ),
                      ],
                      onChanged: (scale) {
                        if (scale != null) {
                          _updateFontSize(context, ref, scale);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Card(
              color: AppColors.card,
              child: SwitchListTile(
                title: Text(
                  context.tr('vibrations'),
                  style: AppTextStyles.labelLarge,
                ),
                subtitle: Text(
                  context.tr('vibrations_description'),
                  style: AppTextStyles.caption,
                ),
                value: settings.vibrationsEnabled,
                activeTrackColor: AppColors.teal,
                onChanged: (enabled) =>
                    _updateVibrations(context, ref, enabled),
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              context.tr('language'),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 8.h),
            const LanguageBar(),
            SizedBox(height: 28.h),
            Text(
              context.tr('profile_title'),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 8.h),
            Card(
              color: AppColors.card,
              child: ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: AppColors.teal,
                ),
                title: Text(
                  context.tr('edit_profile'),
                  style: AppTextStyles.labelLarge,
                ),
                subtitle: Text(
                  context.tr('edit_profile_description'),
                  style: AppTextStyles.caption,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppConstants.routeProfile),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            context.tr('settings_load_error'),
            style: AppTextStyles.bodySmall,
          ),
        ),
      ),
    );
  }

  void _updateFontSize(BuildContext context, WidgetRef ref, double scale) {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.tr('settings_save_error');
    ref
        .read(appPreferencesProvider.notifier)
        .updateFontScale(scale)
        .catchError((_) => _showSaveError(messenger, message));
  }

  void _updateVibrations(BuildContext context, WidgetRef ref, bool enabled) {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.tr('settings_save_error');
    ref
        .read(appPreferencesProvider.notifier)
        .updateVibrationsEnabled(enabled)
        .catchError((_) => _showSaveError(messenger, message));
  }

  void _showSaveError(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
