import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_settings.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/demo_banner.dart';
import '../../data/api/overdrive_api_client.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlCtrl;
  late final TextEditingController _tokenCtrl;
  ConnectionMode _mode = ConnectionMode.embeddedMock;
  bool _testing = false;
  String? _testMessage;
  bool _testOk = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final s = ref.read(appSettingsProvider);
    _mode = s.connectionMode;
    _urlCtrl = TextEditingController(
      text: s.connectionMode == ConnectionMode.live ? s.baseUrl : '',
    );
    _tokenCtrl = TextEditingController(text: s.deviceToken);
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _urlCtrl.dispose();
      _tokenCtrl.dispose();
    }
    super.dispose();
  }

  AppSettings _draft() {
    const port = 18080;
    final base = _mode == ConnectionMode.embeddedMock
        ? 'mock://embedded'
        : normalizeBaseUrl(_urlCtrl.text);
    return AppSettings(
      baseUrl: _mode == ConnectionMode.localMockServer
          ? 'http://127.0.0.1:$port'
          : base,
      deviceToken: _tokenCtrl.text.trim(),
      connectionMode: _mode,
    );
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testMessage = null;
    });
    final draft = _draft();
    final repo = ref.read(vehicleRepositoryProvider);
    repo.updateSettings(draft);
    try {
      final status = await repo.testConnection();
      if (!status.ok) {
        throw Exception('שרת לא זמין');
      }
      await ref.read(vehicleRepositoryProvider.notifier).authenticateAndStoreJwt();
      setState(() {
        _testOk = true;
        _testMessage = 'מחובר. מזהה: ${status.deviceId ?? "--"}';
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
    final draft = _draft();
    await ref.read(appSettingsProvider.notifier).persist(draft);
    await ref.read(vehicleRepositoryProvider.notifier).authenticateAndStoreJwt();
    ref.invalidate(vehicleSnapshotProvider);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OverdriveColors.of(context);
    return Column(
      children: [
        DemoDataBanner(mode: _mode),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text('חיבור לשרת Overdrive ברכב', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Atto 3 ישראל: בדרך כלל פורט 8080 ב-LAN, או מנהרה (Tailscale / Cloudflare / Zrok) עם אותם נתיבי API.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              SegmentedButton<ConnectionMode>(
                segments: [
                  ButtonSegment(
                    value: ConnectionMode.embeddedMock,
                    label: Text('דמו', style: hebrewTextStyle(Theme.of(context).textTheme.labelLarge)),
                    icon: const Icon(Icons.science_outlined),
                  ),
                  ButtonSegment(
                    value: ConnectionMode.live,
                    label: Text('רכב', style: hebrewTextStyle(Theme.of(context).textTheme.labelLarge)),
                    icon: const Icon(Icons.directions_car),
                  ),
                  ButtonSegment(
                    value: ConnectionMode.localMockServer,
                    label: Text(
                      'סימולטור',
                      style: hebrewTextStyle(Theme.of(context).textTheme.labelLarge),
                    ),
                    icon: const Icon(Icons.dns_outlined),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: 20),
              if (_mode == ConnectionMode.live) ...[
                TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'כתובת בסיס (HTTPS מומלץ במנהרה)',
                    hintText: 'https://your-tunnel.example.com',
                  ),
                  keyboardType: TextInputType.url,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _tokenCtrl,
                decoration: InputDecoration(
                  labelText: 'אסימון מכשיר',
                  helperText: 'נשמר מוצפן במכשיר (אימות /auth/token)',
                  helperStyle: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
                  labelStyle: hebrewTextStyle(Theme.of(context).textTheme.bodyLarge),
                ),
                obscureText: true,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
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
                    child: FilledButton.tonalIcon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('שמירה'),
                    ),
                  ),
                ],
              ),
              if (_testMessage != null) ...[
                const SizedBox(height: 16),
                MaterialBanner(
                  content: Text(_testMessage!),
                  backgroundColor: _testOk
                      ? colors.accent.withValues(alpha: 0.15)
                      : colors.danger.withValues(alpha: 0.15),
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => _testMessage = null),
                      child: const Text('סגור'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
