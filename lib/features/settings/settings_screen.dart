import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_settings.dart';
import '../../data/api/overdrive_api_client.dart';
import '../../data/capabilities/companion_parity.dart';
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
        _testMessage = 'מלא כתובת ואסימון';
        _testOk = false;
      });
      return;
    }
    final repo = ref.read(vehicleRepositoryProvider);
    repo.updateSettings(draft);
    try {
      await ref.read(vehicleRepositoryProvider.notifier).authenticateAndStoreJwt();
      final status = await repo.testConnection();
      if (!status.ok) throw Exception('שרת לא זמין');
      setState(() {
        _testOk = true;
        _testMessage = 'מחובר${status.deviceId != null ? " (${status.deviceId})" : ""}';
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
        SegmentedButton<CompanionThemeMode>(
          segments: const [
            ButtonSegment(value: CompanionThemeMode.system, label: Text('מערכת')),
            ButtonSegment(value: CompanionThemeMode.light, label: Text('בהיר')),
            ButtonSegment(value: CompanionThemeMode.dark, label: Text('כהה')),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (s) async {
            final next = settings.copyWith(themeMode: s.first);
            await ref.read(appSettingsProvider.notifier).persist(next);
          },
        ),
        SwitchListTile(
          title: const Text('צבע דינמי (Material You)'),
          subtitle: const Text('Android 12+ — צבעים מהמערכת'),
          value: settings.useDynamicColor,
          onChanged: (v) async {
            await ref.read(appSettingsProvider.notifier).persist(
                  settings.copyWith(useDynamicColor: v),
                );
          },
        ),
        const SizedBox(height: 28),
        Text('יכולות לעומת שרת', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'רשימה זו משקפת את החוזה ב-Overdrive-release. פריטים לא ממומשים לא נשלחים מהאפליקציה.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ...companionParityMatrix.map(
          (e) => ListTile(
            dense: true,
            leading: Icon(
              e.implemented ? Icons.check_circle_outline : Icons.remove_circle_outline,
              color: e.implemented ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            title: Text('${e.method} ${e.path}'),
            subtitle: Text(e.noteHe ?? e.labelHe),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
