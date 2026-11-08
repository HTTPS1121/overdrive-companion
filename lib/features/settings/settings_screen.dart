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
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'חיבור לשרת ',
                      style: hebrewTextStyle(Theme.of(context).textTheme.titleLarge),
                    ),
                    TextSpan(
                      text: 'Overdrive',
                      style: numericTextStyle(Theme.of(context).textTheme.titleLarge),
                    ),
                    TextSpan(
                      text: ' ברכב',
                      style: hebrewTextStyle(Theme.of(context).textTheme.titleLarge),
                    ),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  style: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
                  children: [
                    const TextSpan(text: 'רכב '),
                    TextSpan(
                      text: 'Atto 3',
                      style: numericTextStyle(Theme.of(context).textTheme.bodySmall),
                    ),
                    const TextSpan(text: ' בישראל: פורט '),
                    TextSpan(
                      text: '8080',
                      style: numericTextStyle(Theme.of(context).textTheme.bodySmall),
                    ),
                    const TextSpan(text: ' ברשת מקומית, או מנהרה מאובטחת עם אותם נתיבי שרת.'),
                  ],
                ),
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
                  decoration: InputDecoration(
                    labelText: 'כתובת בסיס שרת',
                    labelStyle: hebrewTextStyle(Theme.of(context).textTheme.bodyLarge),
                    helperText: 'מומלץ HTTPS במנהרה',
                    helperStyle: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
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
                  helperStyle: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
                  labelStyle: hebrewTextStyle(Theme.of(context).textTheme.bodyLarge),
                  helper: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'נשמר מוצפן במכשיר. נתיב אימות ',
                          style: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
                        ),
                        TextSpan(
                          text: '/auth/token',
                          style: numericTextStyle(Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ),
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
                      label: Text(
                        'בדיקת חיבור',
                        style: hebrewTextStyle(Theme.of(context).textTheme.labelLarge),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: Text(
                        'שמירה',
                        style: hebrewTextStyle(Theme.of(context).textTheme.labelLarge),
                      ),
                    ),
                  ),
                ],
              ),
              if (_testMessage != null) ...[
                const SizedBox(height: 16),
                MaterialBanner(
                  content: Text(
                    _testMessage!,
                    style: hebrewTextStyle(Theme.of(context).textTheme.bodyMedium),
                  ),
                  backgroundColor: _testOk
                      ? colors.accent.withValues(alpha: 0.15)
                      : colors.danger.withValues(alpha: 0.15),
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => _testMessage = null),
                      child: Text(
                        'סגור',
                        style: hebrewTextStyle(Theme.of(context).textTheme.labelLarge),
                      ),
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
