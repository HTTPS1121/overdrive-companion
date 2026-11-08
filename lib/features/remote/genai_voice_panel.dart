import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/screenshot_scope.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/voice/genai_voice_client.dart';
import '../../core/voice/mic_permission.dart';
import '../../core/widgets/fixture_disclaimer_banner.dart';
import '../../providers/app_providers.dart';

class GenAiVoicePanel extends ConsumerStatefulWidget {
  const GenAiVoicePanel({super.key, required this.enabled});

  final bool enabled;

  @override
  ConsumerState<GenAiVoicePanel> createState() => _GenAiVoicePanelState();
}

class _GenAiVoicePanelState extends ConsumerState<GenAiVoicePanel> with WidgetsBindingObserver {
  GenAiVoiceClient? _client;
  StreamSubscription<GenAiVoiceEvent>? _sub;
  GenAiVoicePhase _phase = GenAiVoicePhase.idle;
  String _transcript = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_client == null) _bind();
  }

  Future<void> _rebind() async {
    await _sub?.cancel();
    await _client?.dispose();
    _client = null;
    if (!mounted) return;
    _bind();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_sub?.cancel());
    unawaited(_client?.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(_client?.stop(reason: 'App backgrounded'));
    }
  }

  void _bind() {
    final settings = ref.read(appSettingsProvider);
    final jwt = ref.read(vehicleRepositoryProvider).sessionJwt;
    final lang = Localizations.localeOf(context).languageCode;
    final fixture = ScreenshotScope.of(context);
    _client = GenAiVoiceClient(
      baseUrl: settings.baseUrl,
      jwt: jwt,
      language: lang,
      fixtureMic: fixture,
      useTestPlayback: fixture,
    );
    _sub = _client!.events.listen((e) {
      if (!mounted) return;
      setState(() {
        if (e.phase != null) _phase = e.phase!;
        if (e.reason != null && e.phase == GenAiVoicePhase.failed) _error = e.reason;
        if (e.transcript != null) _transcript = e.transcript!;
      });
    });
  }

  Future<void> _toggleSession() async {
    if (!widget.enabled) return;
    if (_phase == GenAiVoicePhase.live || _phase == GenAiVoicePhase.connecting) {
      await _client?.stop();
      return;
    }
    var mic = await MicPermission.status();
    if (mic != MicPermissionOutcome.granted) mic = await MicPermission.request();
    if (mic != MicPermissionOutcome.granted) {
      setState(() => _error = context.l10n.voiceMicDenied);
      return;
    }
    setState(() {
      _error = null;
      _transcript = '';
    });
    await _client?.start();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appSettingsProvider, (_, __) => unawaited(_rebind()));
    ref.listen(vehicleRepositoryProvider, (_, __) => unawaited(_rebind()));
    final l10n = context.l10n;
    final live = _phase == GenAiVoicePhase.live;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FixtureDisclaimerBanner(),
        Text(l10n.genAiVoiceTitle, style: Theme.of(context).textTheme.titleMedium),
        Text(l10n.genAiVoiceHint, style: Theme.of(context).textTheme.bodySmall),
        if (!widget.enabled)
          Text(l10n.voiceFixtureUnsupported, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: !widget.enabled ? null : _toggleSession,
          icon: Icon(live ? Icons.stop_circle_outlined : Icons.record_voice_over),
          label: Text(live ? l10n.genAiVoiceStop : l10n.genAiVoiceStart),
        ),
        if (_transcript.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(_transcript, style: Theme.of(context).textTheme.bodyMedium),
        ],
        if (live)
          TextButton(
            onPressed: () => _client?.truncatePlayback(),
            child: Text(l10n.genAiVoiceTruncate),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ],
    );
  }
}
