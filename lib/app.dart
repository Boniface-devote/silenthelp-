import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/locale_provider.dart';

class SilentHelpApp extends ConsumerWidget {
  const SilentHelpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the locale provider to trigger rebuilds when locale changes
    final selectedLocale = ref.watch(localeProvider);
    
    // Get the current locale from EasyLocalization context
    final currentLocale = context.locale;
    
    // Update the provider if EasyLocalization locale has changed
    // (e.g., if locale was changed from persistent storage on app restart)
    if (selectedLocale != currentLocale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(localeProvider.notifier).state = currentLocale;
      });
    }

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // Material/Cupertino locales that Flutter natively supports
        const supportedMaterialLocales = ['en', 'es', 'fr', 'de', 'it', 'ja', 'zh', 'sw'];
        
        // If current locale is not supported by Material, fallback to English for Material
        final materialLocale = supportedMaterialLocales.contains(selectedLocale.languageCode)
            ? selectedLocale
            : const Locale('en');

        return MaterialApp.router(
          key: ValueKey(selectedLocale.toString()), // Force rebuild when locale changes
          title: 'SilentHelp',
          theme: AppTheme.darkTheme,
          localizationsDelegates: [
            ...context.localizationDelegates,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('sw'),
            Locale('lg'),
          ],
          locale: materialLocale, // Use fallback locale for Material
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
