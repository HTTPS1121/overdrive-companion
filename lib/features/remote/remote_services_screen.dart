import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/remote_services_models.dart';
import '../../providers/app_providers.dart';

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
  CommunicateStatusState? _communicate;
  GenAiStatusState? _genAi;
  WireGuardStatusState? _wireGuard;
  String? _genAiReply;
  bool _busy = false;

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

  Widget _communicateTab(dynamic l10n) {
    final status = _communicate;
    return ListView(
      padding: scrollBottomPadding(context, extra: 24),
      children: [
        FilledButton.tonal(
          onPressed: _busy
              ? null
              : () => _guard(() async {
                    final s = await ref.read(vehicleRepositoryProvider).fetchCommunicateStatus();
                    setState(() => _communicate = s);
                  }),
          child: Text(l10n.communicateLoadStatus),
        ),
        if (status != null) ...[
          ListTile(
            title: Text(l10n.communicateCarState),
            subtitle: Text(status.carState ?? '—'),
          ),
          SwitchListTile(
            title: Text(l10n.communicateAudioReady),
            value: status.audioReady == true,
            onChanged: null,
          ),
          SwitchListTile(
            title: Text(l10n.communicateMessagesReady),
            value: status.messagesReady == true,
            onChanged: null,
          ),
          SwitchListTile(
            title: Text(l10n.communicateListenerReady),
            value: status.listenerReady == true,
            onChanged: null,
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _messageCtrl,
          decoration: InputDecoration(
            labelText: l10n.communicateSendMessage,
            hintText: l10n.communicateMessageHint,
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy
              ? null
              : () => _guard(() async {
                    final r = await ref.read(vehicleRepositoryProvider).postCommunicateMessage(
                          _messageCtrl.text.trim(),
                        );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(r.userMessage(l10n, actionLabel: l10n.communicateSendMessage))),
                    );
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
                        final r = await ref.read(vehicleRepositoryProvider).postCommunicateEmergencyStop();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(r.userMessage(l10n, actionLabel: l10n.communicateEmergencyStop)),
                          ),
                        );
                      }),
              child: Text(l10n.communicateEmergencyStop),
            ),
          ],
        ),
      ],
    );
  }

  Widget _genAiTab(dynamic l10n) {
    return ListView(
      padding: scrollBottomPadding(context, extra: 24),
      children: [
        FilledButton.tonal(
          onPressed: _busy
              ? null
              : () => _guard(() async {
                    final s = await ref.read(vehicleRepositoryProvider).fetchGenAiStatus();
                    setState(() => _genAi = s);
                  }),
          child: Text(l10n.genAiLoadStatus),
        ),
        if (_genAi != null)
          ListTile(
            title: Text(_genAi!.model ?? 'GenAI'),
            subtitle: Text(_genAi!.enabled == true ? 'enabled' : 'disabled'),
          ),
        TextField(
          controller: _genAiCtrl,
          decoration: InputDecoration(
            labelText: l10n.genAiSendChat,
            hintText: l10n.genAiChatHint,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy
              ? null
              : () => _guard(() async {
                    final r = await ref.read(vehicleRepositoryProvider).postGenAiChat(_genAiCtrl.text.trim());
                    setState(() => _genAiReply = r.reply);
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
        OutlinedButton(
          onPressed: _busy
              ? null
              : () => _guard(() async {
                    final dash = await ref.read(vehicleRepositoryProvider).fetchGenAiInsightsDashboard();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(dash['tiles']?.toString() ?? l10n.genAiInsightsOpen)),
                    );
                  }),
          child: Text(l10n.genAiInsightsOpen),
        ),
      ],
    );
  }

  Widget _wireGuardTab(dynamic l10n) {
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
      ],
    );
  }
}
