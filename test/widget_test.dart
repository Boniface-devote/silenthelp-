// SilentHelp Widget Tests
//
// Basic smoke test for the SilentHelp app initialization

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silenthelp/app.dart';

void main() {
  testWidgets('SilentHelp app initializes successfully', (WidgetTester tester) async {
    // Build our app with required wrappers
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('sw'),
          Locale('lg'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const ProviderScope(
          child: SilentHelpApp(),
        ),
      ),
    );

    // Wait for app to load
    await tester.pumpAndSettle();

    // Verify app title is present
    expect(find.text('SILENTHELP'), findsWidgets);
  });
}
