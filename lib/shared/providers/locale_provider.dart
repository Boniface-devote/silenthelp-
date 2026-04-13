import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for managing the active locale
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
