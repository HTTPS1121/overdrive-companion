import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/remote_services_models.dart';
import '../../providers/app_providers.dart';
import 'communicate_voice_panel.dart';
import 'genai_voice_panel.dart';

class RemoteServicesScreen extends ConsumerStatefulWidget {
  const RemoteServicesScreen({super.key});

  @override
  ConsumerState<RemoteServicesScreen> createState() => _RemoteServicesScreenState();
}

class _RemoteServicesScreenState extends ConsumerState<RemoteServicesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _messageCtrl = TextEditingController();
  final _genAiCtrl = TextEditingController();
  final _wgConfigCtrl = TextEditingController();
  CommunicateStatusState? _communicate;
  CommunicateSettingsState? _commSettings;
  GenAiStatusState? _genAi;
  GenAiConfigState? _genAiConfig;
  List<String> _insightTitles = const [];
  WireGuardStatusState? _wireGuard;
  String? _genAiReply;
  bool _busy = false;
  String _messageKind = 'toast';
  int _outputLevel = 70;
  bool _voiceEnabled = true;
  bool _messagesEnabled = true;
  bool _listenerEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _messageCtrl.dispose();
    _genAiCtrl.dispose();
    _wgConfigCtrl.dispose();
    super.dispose();
  }

  Future<void> _guard(Future<void> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadCommunicateBundle() async {
    final repo = ref.read(vehicleRepositoryProvider);
    final status = await repo.fetchCommunicateStatus();
    final settings = await repo.fetchCommunicateSettings();
    setState(() {
      _communicate = status;
      _commSettings = settings;
      _voiceEnabled = settings.voiceEnabled ?? true;
      _messagesEnabled = settings.messagesEnabled ?? true;
      _listenerEnabled = settings.listenerEnabled ?? true;
      _outputLevel = (settings.raw['outputLevel'] as num?)?.toInt() ?? 70;
    });
  }

  Future<void> _saveCommunicateSettings() async {
    final l10n = context.l10n;
    final repo = ref.read(vehicleRepositoryProvider);
    final updated = await repo.postCommunicateSettings({
      'voiceEnabled': _voiceEnabled,
      'messagesEnabled': _messagesEnabled,
      'listenerEnabled': _listenerEnabled,
      'outputLevel': _outputLevel,
    });
    setState(() => _commSettings = updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commonSuccess)),
    );
    await _loadCommunicateBundle();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.remoteServicesTitle),
          bottom: TabBar(
            controller: _tabs,
            tabs: [
              Tab(text: l10n.remoteCommunicateTitle),
              Tab(text: l10n.remoteGenAiTitle),
              Tab(text: l10n.remoteWireGuardTitle),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _communicateTab(l10n),
            _genAiTab(l10n),
            _wireGuardTab(l10n),
          ],
        ),
      ),
    );
  }

  Widget _communicateTab(AppLocalizations l10n) {
    final status = _communicate;
    final messagesReady = status?.messagesReady ?? _messagesEnabled;
    return ListView(
      padding: scrollBottomPadding(context, extra: 24),
      children: [
        FilledButton.tonal(
          onPressed: _busy ? null : () => _guard(_loadCommunicateBundle),
          child: Text(l10n.communicateLoadStatus),
        ),
        if (status != null) ...[
          ListTile(
            title: Text(l10n.communicateCarState),
            subtitle: Text(status.carState ?? '—'),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.communicateAudioReady),
            trailing: Icon(
              status.audioReady == true ? Icons.check_circle : Icons.block,
              color: status.audioReady == true ? Colors.green : null,
            ),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.communicateMessagesReady),
            trailing: Icon(
              messagesReady ? Icons.check_circle : Icons.block,
              color: messagesReady ? Colors.green : null,
            ),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.communicateListenerReady),
            trailing: Icon(
              status.listenerReady == true ? Icons.check_circle : Icons.block,
              color: status.listenerReady == true ? Colors.green : null,
            ),
          ),
        ],
        const Divider(),
        CommunicateVoicePanel(
          voiceReady: status?.audioReady == true && _voiceEnabled,
          listenerReady: status?.listenerReady == true && _listenerEnabled,
        ),
        const Divider(),
        Text(l10n.communicateSettingsTitle, style: Theme.of(context).textTheme.titleSmall),
        SwitchListTile(
          title: Text(l10n.communicateVoiceEnabled),
          value: _voiceEnabled,
          onChanged: _busy ? null : (v) => setState(() => _voiceEnabled = v),
        ),
        SwitchListTile(
          title: Text(l10n.communicateMessagesEnabled),
          value: _messagesEnabled,
          onChanged: _busy ? null : (v) => setState(() => _messagesEnabled = v),
        ),
        SwitchListTile(
          title: Text(l10n.communicateListenerEnabled),
          value: _listenerEnabled,
          onChanged: _busy ? null : (v) => setState(() => _listenerEnabled = v),
        ),
        Text(l10n.communicateOutputLevel),
        Slider(
          value: _outputLevel.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          label: '$_outputLevel',
          onChanged: _busy ? null : (v) => setState(() => _outputLevel = v.round()),
        ),
        FilledButton.tonal(
          onPressed: _busy ? null : () => _guard(_saveCommunicateSettings),
          child: Text(l10n.communicateSaveSettings),
        ),
        const Divider(),
        DropdownButtonFormField<String>(
          initialValue: _messageKind,
          decoration: InputDecoration(labelText: l10n.communicateMessageKind),
          items: [
            DropdownMenuItem(value: 'toast', child: Text(l10n.communicateKindToast)),
            DropdownMenuItem(value: 'dialog', child: Text(l10n.communicateKindDialog)),
          ],
          onChanged: _busy ? null : (v) => setState(() => _messageKind = v ?? 'toast'),
        ),
        TextField(
          controller: _messageCtrl,
          maxLength: 200,
          decoration: InputDecoration(
            labelText: l10n.communicateSendMessage,
            hintText: l10n.communicateMessageHint,
          ),
        ),
        FilledButton(
          onPressed: _busy || !messagesReady
              ? null
              : () => _guard(() async {
                    final r = await ref.read(vehicleRepositoryProvider).postCommunicateMessage(
                          message: _messageCtrl.text.trim(),
                          kind: _messageKind,
                        );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          r.success
                              ? (r.message ?? l10n.commonSuccess)
                              : r.userMessage(l10n, actionLabel: l10n.communicateSendMessage),
                        ),
                      ),
                    );
                    if (r.success) _messageCtrl.clear();
                  }),
          child: Text(l10n.communicateSendMessage),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _guard(() async {
                        final r = await ref.read(vehicleRepositoryProvider).postCommunicateTestSpeaker();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(r.userMessage(l10n, actionLabel: l10n.communicateTestSpeaker)),
                          ),
                        );
                      }),
              child: Text(l10n.communicateTestSpeaker),
            ),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _guard(() async {
                        final ok = await confirmRiskyAction(
                          context,
                          title: l10n.communicateEmergencyStopTitle,
                          body: l10n.communicateEmergencyStopBody,
                          confirmLabel: l10n.communicateEmergencyStop,
                        );
                        if (!ok) return;
                        final r = await ref.read(vehicleRepositoryProvider).postCommunicateEmergencyStop();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(r.userMessage(l10n, actionLabel: l10n.communicateEmergencyStop)),
                          ),
                        );
                        await _loadCommunicateBundle();
                      }),
              child: Text(l10n.communicateEmergencyStop),
            ),
          ],
        ),
      ],
    );
  }

  Widget _genAiTab(AppLocalizations l10n) {
    return ListView(
      padding: scrollBottomPadding(context, extra: 24),
      children: [
        FilledButton.tonal(
          onPressed: _busy
              ? null
              : () => _guard(() async {
                    final repo = ref.read(vehicleRepositoryProvider);
                    final s = await repo.fetchGenAiStatus();
                    final c = await repo.fetchGenAiConfig();
                    setState(() {
                      _genAi = s;
                      _genAiConfig = c;
                    });
                  }),
          child: Text(l10n.genAiLoadStatus),
        ),
        if (_genAi != null)
          ListTile(
            title: Text(_genAi!.model ?? 'GenAI'),
            subtitle: Text(
              [
                if (_genAiConfig?.provider != null) _genAiConfig!.provider!,
                _genAi!.enabled == true ? 'enabled' : 'disabled',
              ].join(' · '),
            ),
          ),
        GenAiVoicePanel(enabled: _genAi?.enabled == true),
        const Divider(),
        TextField(
          controller: _genAiCtrl,
          decoration: InputDecoration(
            labelText: l10n.genAiSendChat,
            hintText: l10n.genAiChatHint,
          ),
          maxLines: 3,
        ),
        FilledButton(
          onPressed: (_busy || _genAi?.enabled == false)
              ? null
              : () => _guard(() async {
                    final r = await ref.read(vehicleRepositoryProvider).postGenAiChat(_genAiCtrl.text.trim());
                    setState(() => _genAiReply = r.reply ?? r.error);
                  }),
          child: Text(l10n.genAiSendChat),
        ),
        if (_genAiReply != null)
          Card(
            child: ListTile(
              title: Text(l10n.genAiReplyTitle),
              subtitle: Text(_genAiReply!),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _guard(() async {
                        final dash = await ref.read(vehicleRepositoryProvider).fetchGenAiInsightsDashboard();
                        if (!mounted) return;
                        final item = dash['item'];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(item?.toString() ?? l10n.genAiInsightsOpen)),
                        );
                      }),
              child: Text(l10n.genAiInsightsOpen),
            ),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _guard(() async {
                        final list = await ref.read(vehicleRepositoryProvider).fetchGenAiInsights();
                        final items = list['items'];
                        final titles = <String>[];
                        if (items is List) {
                          for (final e in items) {
                            if (e is Map && e['title'] != null) titles.add(e['title'].toString());
                          }
                        }
                        setState(() => _insightTitles = titles);
                      }),
              child: Text(l10n.genAiInsightsList),
            ),
            OutlinedButton(
              onPressed: (_busy || _genAi?.enabled == false)
                  ? null
                  : () => _guard(() async {
                        final r = await ref.read(vehicleRepositoryProvider).postGenAiTest();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(r.userMessage(l10n, actionLabel: l10n.genAiTest))),
                        );
                      }),
              child: Text(l10n.genAiTest),
            ),
          ],
        ),
        if (_insightTitles.isNotEmpty)
          ..._insightTitles.map((t) => ListTile(dense: true, title: Text(t))),
      ],
    );
  }

  Widget _wireGuardTab(AppLocalizations l10n) {
    final wg = _wireGuard;
    return ListView(
      padding: scrollBottomPadding(context, extra: 24),
      children: [
        FilledButton.tonal(
          onPressed: _busy
              ? null
              : () => _guard(() async {
                    final s = await ref.read(vehicleRepositoryProvider).fetchWireGuardStatus();
                    setState(() => _wireGuard = s);
                  }),
          child: Text(l10n.wireGuardLoadStatus),
        ),
        if (wg != null) ...[
          ListTile(
            title: Text(wg.configured == true ? l10n.wireGuardConfigured : l10n.wireGuardNotConfigured),
            subtitle: Text(wg.summary ?? ''),
            trailing: Text(wg.running == true ? l10n.wireGuardRunning : '—'),
          ),
          SwitchListTile(
            title: Text(wg.exposeDashboard == true ? l10n.wireGuardExposeOff : l10n.wireGuardExposeOn),
            value: wg.exposeDashboard == true,
            onChanged: _busy
                ? null
                : (v) => _guard(() async {
                      await ref.read(vehicleRepositoryProvider).postWireGuardExpose(enabled: v);
                      final s = await ref.read(vehicleRepositoryProvider).fetchWireGuardStatus();
                      setState(() => _wireGuard = s);
                    }),
          ),
        ],
        const Divider(),
        Text(l10n.wireGuardConfigTitle, style: Theme.of(context).textTheme.titleSmall),
        Text(l10n.wireGuardConfigHint, style: Theme.of(context).textTheme.bodySmall),
        TextField(
          controller: _wgConfigCtrl,
          maxLines: 8,
          decoration: InputDecoration(hintText: l10n.wireGuardConfigPlaceholder),
          textDirection: TextDirection.ltr,
        ),
        FilledButton(
          onPressed: _busy
              ? null
              : () => _guard(() async {
                    final ok = await confirmRiskyAction(
                      context,
                      title: l10n.wireGuardConfigConfirmTitle,
                      body: l10n.wireGuardConfigConfirmBody,
                      confirmLabel: l10n.wireGuardConfigSave,
                    );
                    if (!ok) return;
                    final r = await ref.read(vehicleRepositoryProvider).postWireGuardConfig(
                          _wgConfigCtrl.text.trim(),
                        );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(r.userMessage(l10n, actionLabel: l10n.wireGuardConfigSave))),
                    );
                    final s = await ref.read(vehicleRepositoryProvider).fetchWireGuardStatus();
                    setState(() => _wireGuard = s);
                  }),
          child: Text(l10n.wireGuardConfigSave),
        ),
        OutlinedButton(
          onPressed: _busy
              ? null
              : () => _guard(() async {
                    final ok = await confirmRiskyAction(
                      context,
                      title: l10n.wireGuardConfigDeleteTitle,
                      body: l10n.wireGuardConfigDeleteBody,
                      confirmLabel: l10n.wireGuardConfigDelete,
                    );
                    if (!ok) return;
                    final r = await ref.read(vehicleRepositoryProvider).deleteWireGuardConfig();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(r.userMessage(l10n, actionLabel: l10n.wireGuardConfigDelete))),
                    );
                    _wgConfigCtrl.clear();
                    final s = await ref.read(vehicleRepositoryProvider).fetchWireGuardStatus();
                    setState(() => _wireGuard = s);
                  }),
          child: Text(l10n.wireGuardConfigDelete),
        ),
      ],
    );
  }
}
