import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo/demo_config.dart';
import 'design/od_design.dart';
import 'ui/screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  assert(kCompanionUsesDemoRepository);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: OverdriveCompanionApp()));
}

class OverdriveCompanionApp extends StatelessWidget {
  const OverdriveCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OverDrive',
      theme: buildOdTheme(),
      locale: const Locale('he'),
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
