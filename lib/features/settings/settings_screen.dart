import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_settings.dart';
import '../../data/api/overdrive_api_client.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlCtrl;
  late final TextEditingController _tokenCtrl;
  bool _testing = false;
  String? _testMessage;
  bool _testOk = false;
  bool _fieldsReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fieldsReady) return;
    final s = ref.read(appSettingsProvider);
    _urlCtrl = TextEditingController(text: s.baseUrl);
    _tokenCtrl = TextEditingController(text: s.deviceToken);
    _fieldsReady = true;
  }

  @override
  void dispose() {
    if (_fieldsReady) {
      _urlCtrl.dispose();
      _tokenCtrl.dispose();
    }
    super.dispose();
  }

  AppSettings _draftFromFields() {
    final current = ref.read(appSettingsProvider);
    return current.copyWith(
      baseUrl: normalizeBaseUrl(_urlCtrl.text),
      deviceToken: _tokenCtrl.text.trim(),
    );
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testMessage = null;
    });
    final draft = _draftFromFields();
    if (!draft.isConfigured) {
      setState(() {
        _testing = false;
        _testMessage = 'נא למלא כתובת שרת ואסימון';
        _testOk = false;
      });
      return;
    }
    final repo = ref.read(vehicleRepositoryProvider);
    repo.updateSettings(draft);
    try {
      await ref.read(vehicleRepositoryProvider.notifier).authenticateAndStoreJwt();
      final status = await repo.testConnection();
      if (!status.ok) throw Exception('השרת לא ענה');
      setState(() {
        _testOk = true;
        _testMessage = status.deviceId != null
            ? 'החיבור תקין (מזהה המכשיר בשרת: ${status.deviceId})'
            : 'החיבור תקין';
      });
    } catch (e) {
      setState(() {
        _testOk = false;
        _testMessage = e.toString();
      });
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    final draft = _draftFromFields();
    await ref.read(appSettingsProvider.notifier).persist(draft);
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
        TextField(
          controller: _urlCtrl,
          decoration: const InputDecoration(
            labelText: 'כתובת שרת',
            hintText: 'https://your-tunnel.example.com',
          ),
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tokenCtrl,
          decoration: const InputDecoration(labelText: 'אסימון מכשיר'),
          obscureText: true,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _testing ? null : _test,
                icon: _testing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: const Text('בדיקת חיבור'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _save,
                child: const Text('שמירה'),
              ),
            ),
          ],
        ),
        if (_testMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _testMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _testOk ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
          ),
        ],
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
