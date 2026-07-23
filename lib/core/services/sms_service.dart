import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sends an SMS message.
///
/// On Android: requests SEND_SMS permission and fires the message directly via
/// SmsManager (no SMS app opens, no user confirmation needed).
///
/// On iOS / Web / other platforms: falls back to opening the native SMS app
/// with the number and body pre-filled (the user still taps Send there).
class SmsService {
  static const _channel = MethodChannel('com.example.silenthelp/sms');

  /// Sends [message] to [phone].
  ///
  /// Returns `true` if the message was handed off to the OS successfully.
  /// Throws a [SmsException] if permission is permanently denied or the
  /// native call fails without a usable fallback.
  static Future<bool> sendSms({
    required String phone,
    required String message,
  }) async {
    if (!kIsWeb && Platform.isAndroid) {
      return _sendAndroid(phone: phone, message: message);
    }
    // iOS, Web, desktop — open the SMS app as before
    return _openSmsApp(phone: phone, message: message);
  }

  // ── Android path ─────────────────────────────────────────────────────────

  static Future<bool> _sendAndroid({
    required String phone,
    required String message,
  }) async {
    final status = await Permission.sms.request();

    if (status.isGranted) {
      try {
        final reply = await _channel.invokeMethod<String>('sendSms', {
          'phone': phone,
          'message': message,
        });
        return reply == 'sent';
      } on PlatformException catch (e) {
        // Native call failed — fall back to the SMS app so the message
        // is never silently lost.
        debugPrint('SmsService: native send failed (${e.code}: ${e.message}), '
            'falling back to SMS app.');
        return _openSmsApp(phone: phone, message: message);
      }
    }

    if (status.isPermanentlyDenied) {
      // User has blocked the permission; open app settings and fall back.
      await openAppSettings();
      throw SmsPermissionException(
        'SEND_SMS permission permanently denied. '
        'Please grant it in App Settings and try again.',
      );
    }

    // Denied (but not permanently) — fall back silently.
    debugPrint('SmsService: SEND_SMS permission denied, falling back to SMS app.');
    return _openSmsApp(phone: phone, message: message);
  }

  // ── Fallback: open native SMS app ────────────────────────────────────────

  static Future<bool> _openSmsApp({
    required String phone,
    required String message,
  }) async {
    final uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Thrown when the SEND_SMS permission is permanently denied.
class SmsPermissionException implements Exception {
  final String message;
  const SmsPermissionException(this.message);

  @override
  String toString() => 'SmsPermissionException: $message';
}
