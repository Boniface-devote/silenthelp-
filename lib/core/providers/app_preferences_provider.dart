import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/haptics_service.dart';

class AppPreferences {
  const AppPreferences({this.fontScale = 1, this.vibrationsEnabled = true});

  final double fontScale;
  final bool vibrationsEnabled;

  AppPreferences copyWith({double? fontScale, bool? vibrationsEnabled}) =>
      AppPreferences(
        fontScale: fontScale ?? this.fontScale,
        vibrationsEnabled: vibrationsEnabled ?? this.vibrationsEnabled,
      );
}

class AppPreferencesNotifier extends AsyncNotifier<AppPreferences> {
  static const _fontScaleKey = 'app_font_scale';
  static const _vibrationsEnabledKey = 'app_vibrations_enabled';

  @override
  Future<AppPreferences> build() async {
    final preferences = await SharedPreferences.getInstance();
    final appPreferences = AppPreferences(
      fontScale: preferences.getDouble(_fontScaleKey) ?? 1,
      vibrationsEnabled: preferences.getBool(_vibrationsEnabledKey) ?? true,
    );
    HapticsService.enabled = appPreferences.vibrationsEnabled;
    return appPreferences;
  }

  Future<void> updateFontScale(double fontScale) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_fontScaleKey, fontScale);
    final current = state.valueOrNull ?? const AppPreferences();
    state = AsyncValue.data(current.copyWith(fontScale: fontScale));
  }

  Future<void> updateVibrationsEnabled(bool enabled) async {
    final shouldConfirm = enabled && !HapticsService.enabled;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_vibrationsEnabledKey, enabled);
    HapticsService.enabled = enabled;
    final current = state.valueOrNull ?? const AppPreferences();
    state = AsyncValue.data(current.copyWith(vibrationsEnabled: enabled));
    if (shouldConfirm) await HapticsService.strongConfirmation();
  }
}

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesNotifier, AppPreferences>(
      AppPreferencesNotifier.new,
    );
