import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_settings.dart';
import '../../data/api/overdrive_api_client.dart';
import '../../providers/app_providers.dart';

/// First-run / unconfigured flow — no demo data, real tunnel URL + device token.
class ConnectionSetupScreen extends ConsumerStatefulWidget {
  const ConnectionSetupScreen({super.key});

  @override
  ConsumerState<ConnectionSetupScreen> createState() => _ConnectionSetupScreenState();
}

class _ConnectionSetupScreenState extends ConsumerState<ConnectionSetupScreen> {
  late final TextEditingController _urlCtrl = TextEditingController();
  late final TextEditingController _tokenCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fieldsReady) return;
    final s = ref.read(appSettingsProvider);
    _urlCtrl.text = s.baseUrl;
    _tokenCtrl.text = s.deviceToken;
    _fieldsReady = true;
  }

  bool _fieldsReady = false;

  @override
  void dispose() {
    if (_fieldsReady) {
      _urlCtrl.dispose();
      _tokenCtrl.dispose();
    }
    super.dispose();
  }

  AppSettings _draft() {
    return AppSettings(
      baseUrl: normalizeBaseUrl(_urlCtrl.text),
      deviceToken: _tokenCtrl.text.trim(),
      themeMode: ref.read(appSettingsProvider).themeMode,
      useDynamicColor: ref.read(appSettingsProvider).useDynamicColor,
      pollIntervalSeconds: ref.read(appSettingsProvider).pollIntervalSeconds,
    );
  }

  Future<void> _save() async {
    final draft = _draft();
    if (!draft.isConfigured) {
      setState(() => _error = 'נא למלא כתובת שרת ואסימון מכשיר');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(appSettingsProvider.notifier).persist(draft);
      final repo = ref.read(vehicleRepositoryProvider.notifier);
      repo.rebind(draft);
      await repo.authenticateAndStoreJwt();
      final status = await ref.read(vehicleRepositoryProvider).testConnection();
      if (!status.ok) {
        throw Exception('השרת לא ענה כמצופה');
      }
      ref.invalidate(vehicleSnapshotProvider);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('חיבור לשרת')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Text(
              'התחבר למנהרה של Overdrive ברכב',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'הזן את כתובת בסיס ה-HTTPS של המנהרה ואת אסימון המכשיר מהגדרות הרכב. '
              'ללא חיבור אמיתי לא יוצגו נתוני רכב.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'כתובת שרת (מנהרה)',
                hintText: 'https://example.trycloudflare.com',
              ),
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenCtrl,
              decoration: const InputDecoration(
                labelText: 'אסימון מכשיר',
              ),
              obscureText: true,
              textDirection: TextDirection.ltr,
              autocorrect: false,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('התחבר ושמור'),
            ),
          ],
        ),
      ),
    );
  }
}
