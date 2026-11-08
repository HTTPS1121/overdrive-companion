import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../providers/app_providers.dart';
import 'control_widgets.dart';

/// Remote head-unit shell, voice daemon, and cluster API calls (not local projection UI).
class VehicleHuCommandsPanel extends ConsumerStatefulWidget {
  const VehicleHuCommandsPanel({
    super.key,
    required this.busy,
    required this.onBusyChanged,
    required this.onFeedback,
    this.enabled = true,
  });

  final bool busy;
  final ValueChanged<bool> onBusyChanged;
  final ValueChanged<String?> onFeedback;
  final bool enabled;

  @override
  ConsumerState<VehicleHuCommandsPanel> createState() => _VehicleHuCommandsPanelState();
}

class _VehicleHuCommandsPanelState extends ConsumerState<VehicleHuCommandsPanel> {
  final _speakCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _audioFileCtrl = TextEditingController();
  final _clusterAppCtrl = TextEditingController();
  final _moveXCtrl = TextEditingController(text: '0');
  final _moveYCtrl = TextEditingController(text: '0');
  int _moveDisplay = 0;
  List<dynamic> _clusterApps = const [];

  @override
  void dispose() {
    _speakCtrl.dispose();
    _messageCtrl.dispose();
    _audioFileCtrl.dispose();
    _clusterAppCtrl.dispose();
    _moveXCtrl.dispose();
    _moveYCtrl.dispose();
    super.dispose();
  }

  bool get _can => widget.enabled && !widget.busy;

  Future<void> _runShell(String target, {String? confirmTitle, String? confirmBody}) async {
    final l10n = context.l10n;
    if (confirmTitle != null) {
      final ok = await confirmRiskyAction(
        context,
        title: confirmTitle,
        body: confirmBody ?? l10n.huShellConfirmBody,
        confirmLabel: l10n.controlSend,
      );
      if (ok != true || !mounted) return;
    }
    widget.onBusyChanged(true);
    final result = await ref.read(vehicleRepositoryProvider).systemShellAction(target: target);
    if (!mounted) return;
    widget.onBusyChanged(false);
    final msg = result.userMessage(l10n, actionLabel: target);
    widget.onFeedback(msg);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _sendMoveDisplay() async {
    final l10n = context.l10n;
    final ok = await confirmRiskyAction(
      context,
      title: l10n.huMoveDisplayTitle,
      body: l10n.huShellConfirmBody,
      confirmLabel: l10n.controlSend,
    );
    if (ok != true || !mounted) return;
    widget.onBusyChanged(true);
    final x = int.tryParse(_moveXCtrl.text.trim()) ?? 0;
    final y = int.tryParse(_moveYCtrl.text.trim()) ?? 0;
    final result = await ref.read(vehicleRepositoryProvider).systemShellAction(
          target: 'move_display',
          display: _moveDisplay,
          x: x,
          y: y,
        );
    if (!mounted) return;
    widget.onBusyChanged(false);
    final msg = result.userMessage(l10n, actionLabel: l10n.huMoveDisplayTitle);
    widget.onFeedback(msg);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _voicePost(
    Future<dynamic> Function() call, {
    required String emptyHint,
    required String confirmTitle,
  }) async {
    final l10n = context.l10n;
    final ok = await confirmRiskyAction(
      context,
      title: confirmTitle,
      body: l10n.huVoiceConfirmBody,
      confirmLabel: l10n.controlSend,
    );
    if (ok != true || !mounted) return;
    widget.onBusyChanged(true);
    final result = await call();
    if (!mounted) return;
    widget.onBusyChanged(false);
    final msg = result.userMessage(l10n, actionLabel: confirmTitle);
    widget.onFeedback(msg);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _loadClusterApps() async {
    widget.onBusyChanged(true);
    try {
      final json = await ref.read(vehicleRepositoryProvider).fetchClusterApps();
      final apps = json['apps'] ?? json['items'];
      setState(() => _clusterApps = apps is List ? apps : const []);
    } finally {
      widget.onBusyChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        ControlSection(
          title: l10n.huShellSection,
          icon: Icons.tablet_android,
          children: [
            Text(l10n.huShellHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            ControlActionTile(
              label: l10n.huHome,
              icon: Icons.home,
              enabled: _can,
              onPressed: () => _runShell('home', confirmTitle: l10n.huHome, confirmBody: l10n.huShellConfirmBody),
            ),
            ControlActionTile(
              label: l10n.huBack,
              icon: Icons.arrow_back,
              enabled: _can,
              onPressed: () => _runShell('back', confirmTitle: l10n.huBack, confirmBody: l10n.huShellConfirmBody),
            ),
            ControlActionTile(
              label: l10n.huRecents,
              icon: Icons.apps,
              enabled: _can,
              onPressed: () => _runShell('recents', confirmTitle: l10n.huRecents, confirmBody: l10n.huShellConfirmBody),
            ),
            DropdownButtonFormField<int>(
              value: _moveDisplay,
              decoration: InputDecoration(labelText: l10n.huDisplayId),
              items: const [
                DropdownMenuItem(value: 0, child: Text('0')),
                DropdownMenuItem(value: 1, child: Text('1')),
              ],
              onChanged: _can ? (v) => setState(() => _moveDisplay = v ?? 0) : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _moveXCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.huMoveX),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _moveYCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.huMoveY),
                  ),
                ),
              ],
            ),
            FilledButton.tonal(
              onPressed: _can ? _sendMoveDisplay : null,
              child: Text(l10n.huMoveDisplayTitle),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ControlSection(
          title: l10n.huVoiceSection,
          icon: Icons.record_voice_over,
          children: [
            TextField(
              controller: _audioFileCtrl,
              decoration: InputDecoration(
                labelText: l10n.huAudioFileLabel,
                helperText: l10n.huAudioFileHint,
              ),
            ),
            FilledButton(
              onPressed: !_can || _audioFileCtrl.text.trim().isEmpty
                  ? null
                  : () => _voicePost(
                        () => ref.read(vehicleRepositoryProvider).playHeadUnitAudio(_audioFileCtrl.text.trim()),
                        emptyHint: l10n.integrationsNameRequired,
                        confirmTitle: l10n.huPlayAudio,
                      ),
              child: Text(l10n.huPlayAudio),
            ),
            FilledButton.tonal(
              onPressed: !_can
                  ? null
                  : () => _voicePost(
                        () => ref.read(vehicleRepositoryProvider).stopHeadUnitAudio(),
                        emptyHint: '',
                        confirmTitle: l10n.huStopAudio,
                      ),
              child: Text(l10n.huStopAudio),
            ),
            TextField(
              controller: _speakCtrl,
              maxLines: 2,
              decoration: InputDecoration(labelText: l10n.huSpeakText),
            ),
            FilledButton(
              onPressed: !_can || _speakCtrl.text.trim().isEmpty
                  ? null
                  : () => _voicePost(
                        () => ref.read(vehicleRepositoryProvider).speakOnHeadUnit(_speakCtrl.text.trim()),
                        emptyHint: l10n.integrationsNameRequired,
                        confirmTitle: l10n.huSpeak,
                      ),
              child: Text(l10n.huSpeak),
            ),
            TextField(
              controller: _messageCtrl,
              maxLines: 2,
              decoration: InputDecoration(labelText: l10n.huMessageText),
            ),
            FilledButton(
              onPressed: !_can || _messageCtrl.text.trim().isEmpty
                  ? null
                  : () => _voicePost(
                        () => ref.read(vehicleRepositoryProvider).messageOnHeadUnit(_messageCtrl.text.trim()),
                        emptyHint: l10n.integrationsNameRequired,
                        confirmTitle: l10n.huMessage,
                      ),
              child: Text(l10n.huMessage),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ControlSection(
          title: l10n.huClusterSection,
          icon: Icons.speed,
          children: [
            Text(l10n.huClusterHint, style: Theme.of(context).textTheme.bodySmall),
            TextField(
              controller: _clusterAppCtrl,
              decoration: InputDecoration(labelText: l10n.huClusterAppPackage),
            ),
            FilledButton(
              onPressed: !_can
                  ? null
                  : () async {
                      final l = context.l10n;
                      final ok = await confirmRiskyAction(
                        context,
                        title: l.huClusterCastStart,
                        body: l.huClusterHint,
                        confirmLabel: l.controlSend,
                      );
                      if (ok != true || !mounted) return;
                      widget.onBusyChanged(true);
                      final result = await ref.read(vehicleRepositoryProvider).clusterCast(
                            action: 'start',
                            app: _clusterAppCtrl.text.trim(),
                          );
                      widget.onBusyChanged(false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.userMessage(l, actionLabel: l.huClusterCastStart))),
                        );
                      }
                    },
              child: Text(l10n.huClusterCastStart),
            ),
            FilledButton.tonal(
              onPressed: !_can
                  ? null
                  : () async {
                      final l = context.l10n;
                      final ok = await confirmRiskyAction(
                        context,
                        title: l.huClusterCastStop,
                        body: l.huClusterHint,
                        confirmLabel: l.controlSend,
                      );
                      if (ok != true) return;
                      widget.onBusyChanged(true);
                      final result = await ref.read(vehicleRepositoryProvider).clusterStop();
                      widget.onBusyChanged(false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.userMessage(l, actionLabel: l.huClusterCastStop))),
                        );
                      }
                    },
              child: Text(l10n.huClusterCastStop),
            ),
            TextButton.icon(
              onPressed: _can ? _loadClusterApps : null,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.integrationsRefresh),
            ),
            for (final app in _clusterApps)
              if (app is Map)
                ListTile(
                  dense: true,
                  title: Text(app['label']?.toString() ?? app['package']?.toString() ?? ''),
                  subtitle: Text(app['package']?.toString() ?? ''),
                  onTap: _can
                      ? () => setState(() => _clusterAppCtrl.text = app['package']?.toString() ?? '')
                      : null,
                ),
          ],
        ),
      ],
    );
  }
}
