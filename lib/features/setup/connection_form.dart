import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/connection_errors.dart';
import '../../core/auth/tunnel_credentials.dart';
import '../../core/config/app_settings.dart';
import '../../data/api/overdrive_api_client.dart';
import '../../providers/app_providers.dart';

/// Shared tunnel setup fields — matches Overdrive `login.html` (Device ID + access code).
class ConnectionForm extends ConsumerStatefulWidget {
  const ConnectionForm({
    super.key,
    required this.urlController,
    required this.accessCodeController,
    this.showSaveButton = true,
    this.onBusyChanged,
    this.onError,
    this.onSuccess,
  });

  final TextEditingController urlController;
  final TextEditingController accessCodeController;
  final bool showSaveButton;
  final ValueChanged<bool>? onBusyChanged;
  final ValueChanged<String?>? onError;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends ConsumerState<ConnectionForm> {
  String _deviceId = '';
  bool _loadingId = false;
  String? _deviceIdError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _deviceId = ref.read(appSettingsProvider).deviceId;
  }

  Future<void> _fetchDeviceId() async {
    final url = normalizeBaseUrl(widget.urlController.text);
    if (url.isEmpty) {
      setState(() => _deviceIdError = 'הזן קודם כתובת מנהרה (HTTPS).');
      return;
    }
    setState(() {
      _loadingId = true;
      _deviceIdError = null;
    });
    try {
      final client = ref.read(overdriveApiClientProvider);
      final priorBase = client.baseUrl;
      client.baseUrl = url;
      try {
        final status = await client.fetchAuthStatus();
      if (!status.ok || status.deviceId == null) {
        throw ConnectionFailure(
          ConnectionFailureKind.deviceIdMissing,
          'לא התקבל מזהה מכשיר מ־/auth/status. ודא שהמנהרה פעילה והרכב מחובר.',
        );
      }
        setState(() => _deviceId = status.deviceId!);
        ref.read(appSettingsProvider.notifier).patchDeviceId(status.deviceId!);
      } finally {
        client.baseUrl = priorBase;
      }
    } on OverdriveApiException catch (e) {
      setState(() => _deviceIdError = ConnectionFailure.fromApi(e).messageHe);
    } on ConnectionFailure catch (e) {
      setState(() => _deviceIdError = e.messageHe);
    } catch (e) {
      setState(
        () => _deviceIdError =
            'לא ניתן להגיע למנהרה. בדוק רשת, HTTPS, ושהמנהרה פעילה ברכב.',
      );
    } finally {
      setState(() => _loadingId = false);
    }
  }

  AppSettings _draft() {
    final current = ref.read(appSettingsProvider);
    final code = widget.accessCodeController.text.trim();
    final composed = composeDeviceToken(deviceId: _deviceId, accessCode: code);
    return current.copyWith(
      baseUrl: normalizeBaseUrl(widget.urlController.text),
      deviceId: _deviceId,
      accessCode: code,
      deviceToken: composed,
    );
  }

  Future<void> _connect() async {
    final code = widget.accessCodeController.text.trim();
    final url = normalizeBaseUrl(widget.urlController.text);
    if (url.isEmpty) {
      widget.onError?.call('נא למלא כתובת מנהרה');
      return;
    }
    if (_deviceId.isEmpty) {
      widget.onError?.call('טען מזהה מכשיר מהמנהרה לפני התחברות.');
      return;
    }
    if (!isPlausibleAccessCode(code)) {
      widget.onError?.call('קוד הגישה קצר מדי (לפחות 8 תווים, כמו במסך ההתחברות ברכב).');
      return;
    }
    setState(() => _busy = true);
    widget.onBusyChanged?.call(true);
    widget.onError?.call(null);
    try {
      final draft = _draft();
      ref.read(vehicleRepositoryProvider.notifier).rebind(draft);
      ref.read(vehicleRepositoryProvider).setJwt(null);
      await ref.read(vehicleRepositoryProvider.notifier).authenticateAndStoreJwt();
      final status = await ref.read(vehicleRepositoryProvider).testConnection();
      if (!status.ok) {
        throw ConnectionFailure(
          ConnectionFailureKind.unknown,
          'השרת לא ענה כמצופה לאחר אימות.',
        );
      }
      final jwt = ref.read(vehicleRepositoryProvider).sessionJwt;
      await ref.read(appSettingsProvider.notifier).persist(draft, jwt: jwt);
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
      widget.onSuccess?.call();
    } on ConnectionFailure catch (e) {
      widget.onError?.call(e.messageHe);
    } on OverdriveApiException catch (e) {
      widget.onError?.call(ConnectionFailure.fromApi(e).messageHe);
    } catch (e) {
      widget.onError?.call(e.toString());
    } finally {
      setState(() => _busy = false);
      widget.onBusyChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'אותו תהליך כמו בדפדפן: מזהה מכשיר מהמנהרה + קוד גישה (login.html).',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.urlController,
          decoration: const InputDecoration(
            labelText: 'כתובת מנהרה (HTTPS)',
            hintText: 'https://your-tunnel.trycloudflare.com',
            helperText: 'כתובת שמפנה לשרת Overdrive ברכב — לא לרשת מקומית בלבד',
          ),
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
          autocorrect: false,
          onEditingComplete: _fetchDeviceId,
        ),
        if (isLocalHttpUrl(widget.urlController.text)) ...[
          const SizedBox(height: 8),
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: ListTile(
              leading: Icon(Icons.warning_amber, color: theme.colorScheme.onTertiaryContainer),
              title: const Text('HTTP מקומי בלבד'),
              subtitle: const Text('למנהרה מרחוק נדרש HTTPS.'),
            ),
          ),
        ],
        const SizedBox(height: 16),
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'מזהה מכשיר (Device ID)',
            helperText: 'נטען מ־GET /auth/status — מוצג גם במסך ההתחברות ברכב',
            suffixIcon: _loadingId
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'טען מזהה מהמנהרה',
                    onPressed: _loadingId ? null : _fetchDeviceId,
                  ),
          ),
          child: SelectableText(
            _deviceId.isEmpty ? 'לחץ רענן לאחר הזנת כתובת המנהרה' : _deviceId,
            style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
            textDirection: TextDirection.ltr,
          ),
        ),
        if (_deviceIdError != null) ...[
          const SizedBox(height: 8),
          Text(_deviceIdError!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: widget.accessCodeController,
          decoration: const InputDecoration(
            labelText: 'קוד גישה',
            helperText: 'רק הקוד — לא מזהה המכשיר. השרת משלב: מזהה-קוד',
          ),
          obscureText: true,
          textDirection: TextDirection.ltr,
          autocorrect: false,
        ),
        if (widget.showSaveButton) ...[
          const SizedBox(height: 24),
          FilledButton(
            onPressed: (_busy || _loadingId) ? null : _connect,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('התחבר ושמור'),
          ),
        ],
      ],
    );
  }
}
