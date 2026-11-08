import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/connection_errors.dart';
import '../../core/auth/connection_failure_l10n.dart';
import '../../core/l10n/l10n_x.dart';
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
    final l10n = context.l10n;
    if (url.isEmpty) {
      setState(() => _deviceIdError = l10n.errorTunnelFirst);
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
          l10n.errorDeviceIdFromServer,
        );
      }
        setState(() => _deviceId = status.deviceId!);
        ref.read(appSettingsProvider.notifier).patchDeviceId(status.deviceId!);
      } finally {
        client.baseUrl = priorBase;
      }
    } on OverdriveApiException catch (e) {
      final fail = ConnectionFailure.fromApi(e);
      setState(() => _deviceIdError = fail.localizedMessage(l10n));
    } on ConnectionFailure catch (e) {
      setState(() => _deviceIdError = e.localizedMessage(l10n));
    } catch (e) {
      setState(() => _deviceIdError = l10n.errorTunnelUnreachable);
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
    final l10n = context.l10n;
    if (url.isEmpty) {
      widget.onError?.call(l10n.errorTunnelUrlRequired);
      return;
    }
    if (_deviceId.isEmpty) {
      widget.onError?.call(l10n.errorDeviceIdMissing);
      return;
    }
    if (!isPlausibleAccessCode(code)) {
      widget.onError?.call(l10n.errorAccessCodeShort);
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
          l10n.errorUnexpectedAuth,
        );
      }
      final jwt = ref.read(vehicleRepositoryProvider).sessionJwt;
      await ref.read(appSettingsProvider.notifier).persist(draft, jwt: jwt);
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
      widget.onSuccess?.call();
    } on ConnectionFailure catch (e) {
      widget.onError?.call(e.localizedMessage(l10n));
    } on OverdriveApiException catch (e) {
      widget.onError?.call(ConnectionFailure.fromApi(e).localizedMessage(l10n));
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.connectionIntro,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.urlController,
          decoration: InputDecoration(
            labelText: l10n.tunnelUrlLabel,
            hintText: l10n.tunnelUrlHint,
            helperText: l10n.tunnelUrlHelper,
            helperMaxLines: 3,
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
              title: Text(l10n.localHttpWarningTitle),
              subtitle: Text(l10n.localHttpWarningBody),
            ),
          ),
        ],
        const SizedBox(height: 16),
        InputDecorator(
          decoration: InputDecoration(
            labelText: l10n.deviceIdLabelLong,
            helperText: l10n.deviceIdHelper,
            helperMaxLines: 3,
            suffixIcon: _loadingId
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.refreshDeviceId,
                    onPressed: _loadingId ? null : _fetchDeviceId,
                  ),
          ),
          child: SelectableText(
            _deviceId.isEmpty ? l10n.deviceIdPlaceholder : _deviceId,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'NotoSans',
              letterSpacing: 0.4,
            ),
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
          decoration: InputDecoration(
            labelText: l10n.accessCodeLabel,
            helperText: l10n.accessCodeHelper,
            helperMaxLines: 3,
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
                : Text(l10n.connectSave),
          ),
        ],
      ],
    );
  }
}
