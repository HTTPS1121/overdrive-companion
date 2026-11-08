import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/voice/cabin_audio_client.dart';
import '../../core/voice/communicate_ptt_client.dart';
import '../../core/voice/mic_permission.dart';
import '../../core/layout/screenshot_scope.dart';
import '../../core/widgets/fixture_disclaimer_banner.dart';
import '../../providers/app_providers.dart';

class CommunicateVoicePanel extends ConsumerStatefulWidget {
  const CommunicateVoicePanel({super.key, required this.voiceReady, required this.listenerReady});

  final bool voiceReady;
  final bool listenerReady;

  @override
  ConsumerState<CommunicateVoicePanel> createState() => _CommunicateVoicePanelState();
}

class _CommunicateVoicePanelState extends ConsumerState<CommunicateVoicePanel>
    with WidgetsBindingObserver {
  CommunicatePttClient? _ptt;
  CabinAudioClient? _cabin;
  StreamSubscription<Object?>? _pttSub;
  StreamSubscription<CabinListenerState>? _cabinSub;

  MicPermissionOutcome _micPermission = MicPermissionOutcome.unknown;
  CommunicateTalkPhase _talkPhase = CommunicateTalkPhase.idle;
  CabinListenerPhase _listenerPhase = CabinListenerPhase.idle;
  String? _error;
  var _pcmSent = 0;
  var _listenerBytes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ScreenshotScope.of(context)) {
      _micPermission = MicPermissionOutcome.granted;
    } else {
      unawaited(_refreshMicPermission());
    }
    if (_ptt == null) _bindClients();
  }

  Future<void> _rebindClients() async {
    await _teardownVoice();
    if (!mounted) return;
    _bindClients();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_teardownVoice());
    super.dispose();
  }

  Future<void> _teardownVoice() async {
    await _pttSub?.cancel();
    await _cabinSub?.cancel();
    _pttSub = null;
    _cabinSub = null;
    await _ptt?.dispose();
    await _cabin?.dispose();
    _ptt = null;
    _cabin = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshMicPermission();
    }
  }

  Future<void> _refreshMicPermission() async {
    final s = await MicPermission.status();
    if (!mounted) return;
    setState(() => _micPermission = s);
  }

  void _bindClients() {
    final settings = ref.read(appSettingsProvider);
    final jwt = ref.read(vehicleRepositoryProvider).sessionJwt;
    final base = settings.baseUrl;
    final fixture = ScreenshotScope.of(context);
    _ptt = CommunicatePttClient(baseUrl: base, jwt: jwt, fixtureMic: fixture);
    _cabin = CabinAudioClient(baseUrl: base, jwt: jwt, useTestSink: fixture);
    _pttSub = _ptt!.events.listen((e) {
      if (!mounted) return;
      setState(() {
        if (e.phase != null) _talkPhase = e.phase!;
        if (e.reason != null && e.phase == CommunicateTalkPhase.failed) _error = e.reason;
        if (e.pcmSentBytes != null) _pcmSent = e.pcmSentBytes!;
      });
    });
    _cabinSub = _cabin!.states.listen((s) {
      if (!mounted) return;
      setState(() {
        _listenerPhase = s.phase;
        if (s.phase == CabinListenerPhase.error) _error = s.reason;
        _listenerBytes = _cabin!.playbackBytes;
      });
    });
  }

  Future<bool> _ensureMic() async {
    var s = await MicPermission.status();
    if (s != MicPermissionOutcome.granted) {
      s = await MicPermission.request();
    }
    setState(() => _micPermission = s);
    if (s == MicPermissionOutcome.permanentlyDenied) {
      setState(() => _error = context.l10n.voiceMicOpenSettings);
      return false;
    }
    if (s != MicPermissionOutcome.granted) {
      setState(() => _error = context.l10n.voiceMicDenied);
      return false;
    }
    return true;
  }

  Future<void> _onTalkDown() async {
    if (!widget.voiceReady) return;
    if (!await _ensureMic()) return;
    setState(() => _error = null);
    await _cabin?.setLocalPaused(true);
    await _ptt?.pressDown();
  }

  Future<void> _onTalkUp() async {
    await _ptt?.pressUp();
    await _cabin?.setLocalPaused(false);
  }

  Future<void> _toggleListener(bool on) async {
    if (!widget.listenerReady) return;
    if (on) {
      setState(() => _error = null);
      await _cabin?.connect();
    } else {
      await _cabin?.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appSettingsProvider, (_, __) => unawaited(_rebindClients()));
    ref.listen(vehicleRepositoryProvider, (_, __) => unawaited(_rebindClients()));
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final talkLive = _talkPhase == CommunicateTalkPhase.live;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FixtureDisclaimerBanner(),
        Text(l10n.voicePttTitle, style: theme.textTheme.titleMedium),
        if (!widget.voiceReady)
          Text(l10n.voiceFixtureUnsupported, style: theme.textTheme.bodySmall),
        Text(l10n.voicePttHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        Listener(
          onPointerDown: widget.voiceReady && _micPermission == MicPermissionOutcome.granted
              ? (_) => _onTalkDown()
              : null,
          onPointerUp: (_) => _onTalkUp(),
          onPointerCancel: (_) => _onTalkUp(),
          child: FilledButton.tonalIcon(
            onPressed: !widget.voiceReady
                ? null
                : () async {
                    if (_micPermission != MicPermissionOutcome.granted) {
                      await _ensureMic();
                      return;
                    }
                    if (talkLive) {
                      await _onTalkUp();
                    } else {
                      await _onTalkDown();
                    }
                  },
            icon: Icon(talkLive ? Icons.mic : Icons.mic_none),
            label: Text(_talkLabel(l10n)),
          ),
        ),
        if (talkLive) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_pcmSent / 3200).clamp(0.0, 1.0),
            minHeight: 4,
          ),
        ],
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.voiceCabinListenTitle),
          subtitle: Text(_listenerLabel(l10n)),
          value: _listenerPhase == CabinListenerPhase.live || _listenerPhase == CabinListenerPhase.paused,
          onChanged: !widget.listenerReady
              ? null
              : (v) => _toggleListener(v),
        ),
        if (_listenerBytes > 0)
          Text(l10n.voiceCabinBytes(_listenerBytes.toString()), style: theme.textTheme.bodySmall),
        if (_micPermission == MicPermissionOutcome.permanentlyDenied)
          TextButton(
            onPressed: MicPermission.openSettings,
            child: Text(l10n.voiceMicOpenSettings),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          ),
      ],
    );
  }

  String _talkLabel(dynamic l10n) => switch (_talkPhase) {
        CommunicateTalkPhase.connecting || CommunicateTalkPhase.starting => l10n.voicePttConnecting,
        CommunicateTalkPhase.live => l10n.voicePttLive,
        CommunicateTalkPhase.stopping => l10n.voicePttStopping,
        CommunicateTalkPhase.failed => l10n.voicePttFailed,
        _ => l10n.voicePttHold,
      };

  String _listenerLabel(dynamic l10n) => switch (_listenerPhase) {
        CabinListenerPhase.connecting => l10n.voiceCabinConnecting,
        CabinListenerPhase.live => l10n.voiceCabinLive,
        CabinListenerPhase.paused => l10n.voiceCabinPaused,
        CabinListenerPhase.error => l10n.voiceCabinError,
        _ => l10n.voiceCabinIdle,
      };
}
