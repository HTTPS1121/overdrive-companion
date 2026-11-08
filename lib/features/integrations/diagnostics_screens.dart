import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../core/widgets/fixture_disclaimer_banner.dart';
import '../../core/widgets/requires_connection.dart';
import '../../providers/app_providers.dart';
import 'integrations_loader.dart';

class DiagnosticsHubScreen extends StatelessWidget {
  const DiagnosticsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagnosticsHubTitle)),
      body: ListView(
        padding: scrollBottomPadding(context),
        children: [
          const FixtureDisclaimerBanner(),
          _DiagTile(title: l10n.diagnosticsSeatTitle, screen: const SeatDebugScreen()),
          _DiagTile(title: l10n.diagnosticsLogsTitle, screen: const LogsDiagnosticScreen()),
          _DiagTile(title: l10n.diagnosticsCarPropertyTitle, screen: const CarPropertyDebugScreen()),
          _DiagTile(title: l10n.diagnosticsAdasTitle, screen: const AdasDebugScreen()),
          _DiagTile(title: l10n.diagnosticsLightTitle, screen: const LightDebugScreen()),
          _DiagTile(title: l10n.diagnosticsRemoteKeyTitle, screen: const RemoteKeyDebugScreen()),
          _DiagTile(title: l10n.diagnosticsAutoServiceTitle, screen: const AutoServiceDebugScreen()),
          _DiagTile(title: l10n.integrationsRoadSenseTitle, screen: const RoadSenseToolsScreen()),
        ],
      ),
    );
  }
}

class _DiagTile extends StatelessWidget {
  const _DiagTile({required this.title, required this.screen});
  final String title;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen)),
    );
  }
}

class SeatDebugScreen extends ConsumerStatefulWidget {
  const SeatDebugScreen({super.key});

  @override
  ConsumerState<SeatDebugScreen> createState() => _SeatDebugScreenState();
}

class _SeatDebugScreenState extends ConsumerState<SeatDebugScreen> with FamilyLoaderMixin {
  Map<String, dynamic>? _data;
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      busy = true;
      _error = '';
    });
    try {
      final json = await ref.read(extendedServicesRepositoryProvider).readSeatDebug();
      setState(() => _data = json);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.diagnosticsSeatTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            const FixtureDisclaimerBanner(),
            if (_error.isNotEmpty) ListTile(title: Text(l10n.commonError), subtitle: Text(_error)),
            if (_data != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(_data.toString()),
              ),
            FilledButton(onPressed: busy ? null : _load, child: Text(l10n.integrationsRefresh)),
          ],
        ),
      ),
    );
  }
}

class LogsDiagnosticScreen extends ConsumerStatefulWidget {
  const LogsDiagnosticScreen({super.key});

  @override
  ConsumerState<LogsDiagnosticScreen> createState() => _LogsDiagnosticScreenState();
}

class _LogsDiagnosticScreenState extends ConsumerState<LogsDiagnosticScreen> with FamilyLoaderMixin {
  Map<String, dynamic>? _available;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await guard(() async {
      _available = await ref.read(extendedServicesRepositoryProvider).fetchLogsAvailable();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daemons = _available?['daemons'];
    final list = daemons is List ? daemons.map((e) => e.toString()).toList() : <String>[];
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.diagnosticsLogsTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            const FixtureDisclaimerBanner(),
            if (_available?['available'] != true)
              ListTile(title: Text(l10n.diagnosticsLogsUnavailable)),
            for (final d in list)
              ListTile(
                title: Text(d),
                trailing: FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final ok = await confirmRiskyAction(
                            context,
                            title: l10n.diagnosticsLogsUploadTitle,
                            body: l10n.platformDestructiveWarning,
                            confirmLabel: l10n.actionConfirm,
                          );
                          if (ok != true) return;
                          await guard(() async {
                            final r = await ref.read(extendedServicesRepositoryProvider).uploadLogDaemon(d);
                            if (mounted) await integrationSnack(context, r['code']?.toString() ?? l10n.commonSuccess);
                          });
                        },
                  child: Text(l10n.diagnosticsLogsUpload),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CarPropertyDebugScreen extends ConsumerStatefulWidget {
  const CarPropertyDebugScreen({super.key});

  @override
  ConsumerState<CarPropertyDebugScreen> createState() => _CarPropertyDebugScreenState();
}

class _CarPropertyDebugScreenState extends ConsumerState<CarPropertyDebugScreen> with FamilyLoaderMixin {
  final _keyCtrl = TextEditingController(text: '0x11400008');
  String _result = '';

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.diagnosticsCarPropertyTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            const FixtureDisclaimerBanner(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _keyCtrl,
                decoration: InputDecoration(labelText: l10n.diagnosticsPropertyKeyLabel),
              ),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () => guard(() async {
                        final status =
                            await ref.read(extendedServicesRepositoryProvider).fetchCarPropertyStatus();
                        final value = await ref.read(extendedServicesRepositoryProvider).readCarProperty(
                              _keyCtrl.text.trim(),
                            );
                        setState(() => _result = 'status=$status\nvalue=$value');
                      }),
              child: Text(l10n.integrationsRefresh),
            ),
            if (_result.isNotEmpty)
              Padding(padding: const EdgeInsets.all(16), child: SelectableText(_result)),
          ],
        ),
      ),
    );
  }
}

class AdasDebugScreen extends ConsumerStatefulWidget {
  const AdasDebugScreen({super.key});

  @override
  ConsumerState<AdasDebugScreen> createState() => _AdasDebugScreenState();
}

class _AdasDebugScreenState extends ConsumerState<AdasDebugScreen> with FamilyLoaderMixin {
  String _body = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.diagnosticsAdasTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            const FixtureDisclaimerBanner(),
            FilledButton(
              onPressed: busy
                  ? null
                  : () => guard(() async {
                        final resolve = await ref.read(extendedServicesRepositoryProvider).resolveAdas();
                        final read = await ref.read(extendedServicesRepositoryProvider).readAdasRegisters();
                        setState(() => _body = 'resolve=$resolve\nread=$read');
                      }),
              child: Text(l10n.integrationsRefresh),
            ),
            if (_body.isNotEmpty)
              Padding(padding: const EdgeInsets.all(16), child: SelectableText(_body)),
          ],
        ),
      ),
    );
  }
}

class LightDebugScreen extends ConsumerWidget {
  const LightDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.diagnosticsLightTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            const FixtureDisclaimerBanner(),
            Text(l10n.diagnosticsLightReadOnly, style: Theme.of(context).textTheme.bodySmall),
            FutureBuilder(
              future: ref.read(extendedServicesRepositoryProvider).resolveLightDebug(),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) return ListTile(title: Text(snap.error.toString()));
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(snap.data.toString()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RemoteKeyDebugScreen extends ConsumerWidget {
  const RemoteKeyDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.diagnosticsRemoteKeyTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            const FixtureDisclaimerBanner(),
            FutureBuilder(
              future: ref.read(extendedServicesRepositoryProvider).fetchRemoteKeyDebug(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(snap.data.toString()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AutoServiceDebugScreen extends ConsumerWidget {
  const AutoServiceDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.diagnosticsAutoServiceTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            const FixtureDisclaimerBanner(),
            FutureBuilder(
              future: ref.read(extendedServicesRepositoryProvider).fetchAutoServiceDebugStatus(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(snap.data.toString()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoadSenseToolsScreen extends ConsumerStatefulWidget {
  const RoadSenseToolsScreen({super.key});

  @override
  ConsumerState<RoadSenseToolsScreen> createState() => _RoadSenseToolsScreenState();
}

class _RoadSenseToolsScreenState extends ConsumerState<RoadSenseToolsScreen> with FamilyLoaderMixin {
  Map<String, dynamic>? _hazards;
  String _severity = 'moderate';
  String _channel = 'navigation';
  final _volumeCtrl = TextEditingController(text: '70');

  @override
  void dispose() {
    _volumeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await guard(() async {
      _hazards = await ref.read(extendedServicesRepositoryProvider).fetchRoadSenseHazards();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = _hazards?['features'];
    final count = features is List ? features.length : 0;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.integrationsRoadSenseTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            const FixtureDisclaimerBanner(),
            ListTile(title: Text(l10n.roadSenseHazardCount), subtitle: Text('$count')),
            DropdownButtonFormField<String>(
              value: _severity,
              decoration: InputDecoration(labelText: l10n.roadSenseSeverity),
              items: const [
                DropdownMenuItem(value: 'minor', child: Text('minor')),
                DropdownMenuItem(value: 'moderate', child: Text('moderate')),
                DropdownMenuItem(value: 'severe', child: Text('severe')),
              ],
              onChanged: busy ? null : (v) => setState(() => _severity = v ?? _severity),
            ),
            DropdownButtonFormField<String>(
              value: _channel,
              decoration: InputDecoration(labelText: l10n.roadSenseChannel),
              items: const [
                DropdownMenuItem(value: 'navigation', child: Text('navigation')),
                DropdownMenuItem(value: 'media', child: Text('media')),
              ],
              onChanged: busy ? null : (v) => setState(() => _channel = v ?? _channel),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _volumeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.roadSenseVolumePercent),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => guard(() async {
                          final vol = int.tryParse(_volumeCtrl.text) ?? 70;
                          final r = await ref.read(extendedServicesRepositoryProvider).postRoadSenseTestChime({
                            'severity': _severity,
                            'channel': _channel,
                            'volumePercent': vol.clamp(10, 100),
                          });
                          if (mounted) await integrationSnack(context, r['success'] == true ? l10n.commonSuccess : l10n.commonError);
                        }),
                child: Text(l10n.roadSenseTestChime),
              ),
            ),
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () async {
                      final ok = await confirmRiskyAction(
                        context,
                        title: l10n.roadSenseDeleteLocalTitle,
                        body: l10n.roadSenseDeleteLocalBody,
                        confirmLabel: l10n.actionDelete,
                      );
                      if (ok != true) return;
                      await guard(() async {
                        await ref.read(extendedServicesRepositoryProvider).postRoadSenseDeleteLocal();
                        await _load();
                      });
                    },
              child: Text(l10n.roadSenseDeleteLocal),
            ),
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () async {
                      final ok = await confirmRiskyAction(
                        context,
                        title: l10n.roadSenseDeleteCloudTitle,
                        body: l10n.roadSenseDeleteCloudBody,
                        confirmLabel: l10n.actionDelete,
                      );
                      if (ok != true) return;
                      await guard(() async {
                        await ref.read(extendedServicesRepositoryProvider).postRoadSenseDeleteCloud();
                      });
                    },
              child: Text(l10n.roadSenseDeleteCloud),
            ),
            if (features is List)
              for (final f in features)
                if (f is Map)
                  ListTile(
                    title: Text(f['properties']?['kind']?.toString() ?? 'hazard'),
                    subtitle: Text(f['properties']?['id']?.toString() ?? ''),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => guard(() async {
                            final id = f['properties']?['id']?.toString();
                            if (id == null) return;
                            await ref.read(extendedServicesRepositoryProvider).postRoadSenseHazardVerdict(id, true);
                            await _load();
                          }),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => guard(() async {
                            final id = f['properties']?['id']?.toString();
                            if (id == null) return;
                            await ref.read(extendedServicesRepositoryProvider).postRoadSenseHazardVerdict(id, false);
                            await _load();
                          }),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
