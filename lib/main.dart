import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/fonts/bundled_fonts.dart';
import 'providers/app_providers.dart';
import 'providers/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ensureBundledFontsLoaded();
  final settingsRepo = await SettingsRepository.create();
  final initialSettings = await settingsRepo.loadFull();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
      ],
      child: OverdriveApp(initialSettings: initialSettings),
    ),
  );
}
