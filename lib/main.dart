import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/secure_settings_store.dart';
import 'design/od_design.dart';
import 'state/companion_app_controller.dart';
import 'ui/feedback/od_feedback.dart';
import 'ui/screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsStore = await SecureSettingsStore.open();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ProviderScope(
      overrides: [
        secureSettingsStoreProvider.overrideWithValue(settingsStore),
      ],
      child: const OverdriveCompanionApp(),
    ),
  );
}

class OverdriveCompanionApp extends StatelessWidget {
  const OverdriveCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: odRootScaffoldMessengerKey,
      title: 'OverDrive',
      theme: buildOdTheme(),
      locale: const Locale('he'),
      builder: (context, child) {
        final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Material(
            color: Colors.transparent,
            child: DefaultTextStyle.merge(
              style: base.copyWith(decoration: TextDecoration.none, decorationColor: Colors.transparent),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: const MainShell(),
    );
  }
}
