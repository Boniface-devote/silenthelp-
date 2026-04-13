import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class SilentHelpApp extends ConsumerWidget {
  const SilentHelpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // Get the current locale from EasyLocalization
        final currentLocale = context.locale;
        
        // Material/Cupertino locales that Flutter natively supports
        const supportedMaterialLocales = ['en', 'es', 'fr', 'de', 'it', 'ja', 'zh', 'sw'];
        
        // If current locale is not supported by Material, fallback to English for Material
        // but keep the custom app translations from EasyLocalization
        final materialLocale = supportedMaterialLocales.contains(currentLocale.languageCode)
            ? currentLocale
            : const Locale('en');

        return MaterialApp.router(
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
