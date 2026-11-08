import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/auth/tunnel_credentials.dart';
import '../../providers/app_providers.dart';
import 'connection_form.dart';

/// First-run — tunnel URL, Device ID from /auth/status, access code (login.html parity).
class ConnectionSetupScreen extends ConsumerStatefulWidget {
  const ConnectionSetupScreen({super.key});

  @override
  ConsumerState<ConnectionSetupScreen> createState() => _ConnectionSetupScreenState();
}

class _ConnectionSetupScreenState extends ConsumerState<ConnectionSetupScreen> {
  late final TextEditingController _urlCtrl = TextEditingController();
  late final TextEditingController _codeCtrl = TextEditingController();
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final s = ref.read(appSettingsProvider);
    _urlCtrl.text = s.baseUrl;
    if (s.accessCode.isNotEmpty) {
      _codeCtrl.text = s.accessCode;
    } else {
      final parsed = parseDeviceToken(s.deviceToken);
      if (parsed != null) _codeCtrl.text = parsed.accessCode;
    }
    _initialized = true;
  }

  bool _initialized = false;

  @override
  void dispose() {
    if (_initialized) {
      _urlCtrl.dispose();
      _codeCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.connectionTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Text(context.l10n.connectionScreenTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              context.l10n.connectionIntroLong,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ConnectionForm(
              urlController: _urlCtrl,
              accessCodeController: _codeCtrl,
              onError: (e) => setState(() => _error = e),
              onSuccess: () => setState(() => _error = null),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
