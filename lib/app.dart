import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_settings.dart';
import 'core/layout/phone_viewport.dart';
import 'core/layout/screenshot_scope.dart';
import 'core/theme/companion_color_schemes.dart';
import 'core/theme/companion_theme.dart';
import 'features/shell/app_root.dart';
import 'providers/app_providers.dart';

class OverdriveApp extends ConsumerStatefulWidget {
  const OverdriveApp({
    super.key,
    required this.initialSettings,
    this.screenshotBoundaryKey,
    this.lockPhoneViewport = false,
    this.screenshotMode = false,
  });

  final AppSettings initialSettings;
  final GlobalKey? screenshotBoundaryKey;
  final bool lockPhoneViewport;
  /// Test-only: skip bootstrap that would overwrite Riverpod overrides.
  final bool screenshotMode;

  @override
  ConsumerState<OverdriveApp> createState() => _OverdriveAppState();
}

class _OverdriveAppState extends ConsumerState<OverdriveApp> {
  @override
  void initState() {
    super.initState();
    if (!widget.screenshotMode) {
      Future.microtask(() async {
        ref.read(appSettingsProvider.notifier).applyInitial(widget.initialSettings);
        await ref.read(appSettingsProvider.notifier).bootstrap();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    Widget home = ScreenshotScope(
      active: widget.screenshotMode,
      child: const AppRoot(),
    );
    if (widget.lockPhoneViewport) {
      home = PhoneViewport(child: home);
    }
    if (widget.screenshotBoundaryKey != null) {
      home = RepaintBoundary(key: widget.screenshotBoundaryKey, child: home);
    }

    final localizations = const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    Locale? localeResolution(Locale? locale, Iterable<Locale> supported) {
      if (locale == null) return const Locale('en');
      for (final s in supported) {
        if (s.languageCode == locale.languageCode) return s;
      }
      return const Locale('en');
    }

    final screenshotLocale =
        widget.screenshotMode ? const Locale('he') : null;

    if (!settings.useDynamicColor) {
      return MaterialApp(
        title: 'Overdrive Companion',
        debugShowCheckedModeBanner: false,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: screenshotLocale,
        localeResolutionCallback: localeResolution,
        localizationsDelegates: localizations,
        theme: companionLightTheme(),
        darkTheme: companionDarkTheme(),
        themeMode: settings.materialThemeMode,
        home: home,
      );
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Overdrive Companion',
          debugShowCheckedModeBanner: false,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: screenshotLocale,
          localeResolutionCallback: localeResolution,
          localizationsDelegates: localizations,
          theme: companionLightTheme(
            colorScheme: lightDynamic ?? CompanionColorSchemes.light,
          ),
          darkTheme: companionDarkTheme(
            colorScheme: darkDynamic ?? CompanionColorSchemes.dark,
          ),
          themeMode: settings.materialThemeMode,
          home: home,
        );
      },
    );
  }
}
