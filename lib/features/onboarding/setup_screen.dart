import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_settings.dart';
import '../../data/api/overdrive_api_client.dart';
import '../../providers/app_providers.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
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
    _urlCtrl = TextEditingController(text: s.baseUrl);
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
    final port = 18080;
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
      final deviceId = status.deviceId ?? '—';
      setState(() {
        _testOk = true;
        _testMessage = 'מחובר. מזהה מכשיר: $deviceId';
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
    await ref.read(appSettingsProvider.notifier).persist(_draft());
    ref.invalidate(vehicleSnapshotProvider);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('הגדרות Overdrive')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'כתובת שרת הרכב',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ConnectionMode>(
              segments: const [
                ButtonSegment(
                  value: ConnectionMode.embeddedMock,
                  label: Text('דמו מובנה'),
                ),
                ButtonSegment(
                  value: ConnectionMode.live,
                  label: Text('רכב / מנהרה'),
                ),
                ButtonSegment(
                  value: ConnectionMode.localMockServer,
                  label: Text('Mock HTTP'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 16),
            if (_mode != ConnectionMode.embeddedMock) ...[
              TextField(
                controller: _urlCtrl,
                decoration: InputDecoration(
                  labelText: _mode == ConnectionMode.live
                      ? 'Base URL (LAN / Zrok / Cloudflare / Tailscale)'
                      : 'לא נדרש — משתמש ב-127.0.0.1:18080',
                  hintText: 'https://your-tunnel.example.com',
                  enabled: _mode == ConnectionMode.live,
                ),
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _tokenCtrl,
              decoration: const InputDecoration(
                labelText: 'Device token (מהמסך ברכב)',
                helperText: 'POST /auth/token — נדרש דרך מנהרה; ב-LAN לעיתים לא',
              ),
              obscureText: true,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
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
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('שמירה והמשך'),
                ),
              ],
            ),
            if (_testMessage != null) ...[
              const SizedBox(height: 16),
              MaterialBanner(
                content: Text(_testMessage!),
                backgroundColor: _testOk
                    ? Colors.green.shade50
                    : Theme.of(context).colorScheme.errorContainer,
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _testMessage = null),
                    child: const Text('סגור'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'טיפ: ברכב Overdrive בדרך כלל פורט 8080. מנהרה = אותו נתיב API, רק HTTPS.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
