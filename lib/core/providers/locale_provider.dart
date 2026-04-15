import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateProvider that tracks the current locale
/// This allows Riverpod to notify widgets when the locale changes
/// Initial locale is English
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en');
});
