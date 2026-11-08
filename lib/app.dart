import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_providers.dart';

import 'core/config/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/main_shell.dart';

class OverdriveApp extends ConsumerStatefulWidget {
  const OverdriveApp({super.key, required this.initialSettings});

  final AppSettings initialSettings;

  @override
  ConsumerState<OverdriveApp> createState() => _OverdriveAppState();
}

class _OverdriveAppState extends ConsumerState<OverdriveApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(appSettingsProvider.notifier).applyInitial(widget.initialSettings);
      await ref.read(appSettingsProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overdrive Companion',
      debugShowCheckedModeBanner: false,
      theme: buildOverdriveTheme(),
      locale: const Locale('he'),
      supportedLocales: const [Locale('he'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MainShell(),
    );
  }
}
