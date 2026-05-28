import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/providers/theme_mode_provider.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/core/theme/app_theme.dart';

class KrishiSmartApp extends ConsumerWidget {
  const KrishiSmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Krishi Smart',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(languageCode: locale),
      darkTheme: AppTheme.dark(languageCode: locale),
      locale: locale == 'ne' ? const Locale('ne') : const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ne')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
