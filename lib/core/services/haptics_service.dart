import 'package:flutter/services.dart';

class HapticsService {
  HapticsService._();

  static bool enabled = true;

  static Future<void> lightImpact() =>
      enabled ? HapticFeedback.lightImpact() : Future.value();

  static Future<void> mediumImpact() =>
      enabled ? HapticFeedback.mediumImpact() : Future.value();

  static Future<void> heavyImpact() =>
      enabled ? HapticFeedback.heavyImpact() : Future.value();

  static Future<void> selectionClick() =>
      enabled ? HapticFeedback.selectionClick() : Future.value();

  static Future<void> strongConfirmation() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 110));
    await HapticFeedback.heavyImpact();
  }
}
