import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Result from an SMS send operation.
///
/// `sent` indicates whether Android accepted the SMS send request.
/// `deliveryConfirmed` indicates whether a delivery report was received.
class SmsSendResult {
  final bool sent;
  final bool deliveryConfirmed;
  final String status;
  final String? errorMessage;

  const SmsSendResult({
    required this.sent,
    required this.deliveryConfirmed,
    required this.status,
    this.errorMessage,
  });
}

/// Sends an SMS message.
///
/// On Android: requests SEND_SMS permission and dispatches the message through
/// native SmsManager, using send and delivery intents to confirm send and
/// delivery status.
///
/// On iOS / Web / other platforms: falls back to opening the native SMS app
/// with the number and body pre-filled.
class SmsService {
  static const _channel = MethodChannel('com.example.silenthelp/sms');

  /// Sends [message] to [phone].
  ///
  /// Returns structured send/delivery state rather than a simple success bool.
  static Future<SmsSendResult> sendSms({
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

  static Future<SmsSendResult> _sendAndroid({
    required String phone,
    required String message,
  }) async {
    final status = await Permission.sms.request();

    if (status.isGranted) {
      try {
        final reply = await _channel.invokeMapMethod<String, dynamic>('sendSms', {
          'phone': phone,
          'message': message,
        });

        if (reply == null) {
          return const SmsSendResult(
            sent: false,
            deliveryConfirmed: false,
            status: 'platform_no_response',
            errorMessage: 'No response from SMS platform channel.',
          );
        }

        return SmsSendResult(
          sent: reply['sent'] == true,
          deliveryConfirmed: reply['delivered'] == true,
          status: reply['status']?.toString() ?? 'unknown',
          errorMessage: reply['error']?.toString(),
        );
      } on PlatformException catch (e) {
        debugPrint('SmsService: native send failed (${e.code}: ${e.message}), '
            'falling back to SMS app.');
        return _openSmsApp(phone: phone, message: message);
      }
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      throw SmsPermissionException(
        'SEND_SMS permission permanently denied. '
        'Please grant it in App Settings and try again.',
      );
    }

    debugPrint('SmsService: SEND_SMS permission denied, falling back to SMS app.');
    return _openSmsApp(phone: phone, message: message);
  }

  // ── Fallback: open native SMS app ────────────────────────────────────────

  static Future<SmsSendResult> _openSmsApp({
    required String phone,
    required String message,
  }) async {
    final uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    return SmsSendResult(
      sent: false,
      deliveryConfirmed: false,
      status: opened ? 'sms_app_opened' : 'sms_app_open_failed',
      errorMessage: opened ? null : 'Could not open SMS app.',
    );
  }
}

/// Thrown when the SEND_SMS permission is permanently denied.
class SmsPermissionException implements Exception {
  final String message;
  const SmsPermissionException(this.message);

  @override
  String toString() => 'SmsPermissionException: $message';
}
