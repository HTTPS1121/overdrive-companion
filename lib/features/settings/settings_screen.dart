import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/tunnel_credentials.dart';
import '../../core/config/app_settings.dart';
import '../../data/api/overdrive_api_client.dart';
import '../../providers/app_providers.dart';
import '../setup/connection_form.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlCtrl;
  late final TextEditingController _codeCtrl;
  bool _fieldsReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fieldsReady) return;
    final s = ref.read(appSettingsProvider);
    _urlCtrl = TextEditingController(text: s.baseUrl);
    _codeCtrl = TextEditingController(
      text: s.accessCode.isNotEmpty
          ? s.accessCode
          : (parseDeviceToken(s.deviceToken)?.accessCode ?? ''),
    );
    _fieldsReady = true;
  }

  @override
  void dispose() {
    if (_fieldsReady) {
      _urlCtrl.dispose();
      _codeCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final current = ref.read(appSettingsProvider);
    final deviceId = current.deviceId;
    final composed = composeDeviceToken(deviceId: deviceId, accessCode: _codeCtrl.text.trim());
    final draft = current.copyWith(
      baseUrl: normalizeBaseUrl(_urlCtrl.text),
      accessCode: _codeCtrl.text.trim(),
      deviceToken: composed,
    );
    await ref.read(appSettingsProvider.notifier).persist(draft, clearJwt: true);
    await ref.read(vehicleRepositoryProvider.notifier).authenticateAndStoreJwt();
    ref.invalidate(vehicleSnapshotProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ההגדרות נשמרו')),
      );
    }
  }

  Future<void> _setThemeMode(CompanionThemeMode mode) async {
    final settings = ref.read(appSettingsProvider);
    await ref.read(appSettingsProvider.notifier).persist(settings.copyWith(themeMode: mode));
  }

  @override
  Widget build(BuildContext context) {
    if (!_fieldsReady) {
      return const Center(child: CircularProgressIndicator());
    }
    final settings = ref.watch(appSettingsProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text('חיבור', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        ConnectionForm(
          urlController: _urlCtrl,
          accessCodeController: _codeCtrl,
          showSaveButton: false,
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _save, child: const Text('שמירה והתחברות')),
        const SizedBox(height: 28),
        Text('תצוגה', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'מצב בהיר / כהה / לפי המערכת. צבע דינמי דורש Android 12+.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Wrap(
            spacing: 8,
            children: [
              for (final mode in CompanionThemeMode.values)
                FilterChip(
                  label: Text(_themeLabel(mode)),
                  selected: settings.themeMode == mode,
                  onSelected: (_) => _setThemeMode(mode),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('צבעים דינמיים (Material You)'),
          subtitle: const Text('לפי ערכת הצבעים של המכשיר'),
          trailing: Switch(
            value: settings.useDynamicColor,
            onChanged: (v) async {
              await ref.read(appSettingsProvider.notifier).persist(
                    settings.copyWith(useDynamicColor: v),
                  );
            },
          ),
        ),
      ],
    );
  }

  static String _themeLabel(CompanionThemeMode mode) => switch (mode) {
        CompanionThemeMode.system => 'מערכת',
        CompanionThemeMode.light => 'בהיר',
        CompanionThemeMode.dark => 'כהה',
      };
}
