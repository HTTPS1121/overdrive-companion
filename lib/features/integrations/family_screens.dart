import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/extended_services_models.dart';
import '../../providers/app_providers.dart';

Future<void> _snack(BuildContext context, String text) {
  return Future.microtask(() {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  });
}

mixin _FamilyLoader<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool busy = false;

  Future<void> guard(Future<void> Function() fn) async {
    setState(() => busy = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) await _snack(context, e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class AutomationsFamilyScreen extends ConsumerStatefulWidget {
  const AutomationsFamilyScreen({super.key});

  @override
  ConsumerState<AutomationsFamilyScreen> createState() => _AutomationsFamilyScreenState();
}

class _AutomationsFamilyScreenState extends ConsumerState<AutomationsFamilyScreen>
    with _FamilyLoader {
  List<AutomationEntry> _items = const [];
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await guard(() async {
      final list = await ref.read(extendedServicesRepositoryProvider).listAutomations();
      setState(() => _items = list.automations);
    });
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      await _snack(context, l10n.integrationsNameRequired);
      return;
    }
    await guard(() async {
      await ref.read(extendedServicesRepositoryProvider).createAutomation(name: name);
      _nameCtrl.clear();
      await _reload();
      if (mounted) await _snack(context, l10n.integrationsSaved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.integrationsAutomationsTitle)),
        floatingActionButton: busy ? null : FloatingActionButton.extended(onPressed: _reload, label: Text(l10n.integrationsRefresh)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.integrationsAutomationNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(onPressed: busy ? null : _create, child: Text(l10n.integrationsCreateAutomation)),
            ),
            const SizedBox(height: 16),
            for (final a in _items)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(a.name),
                  subtitle: Text('${a.id} · ${a.mode ?? '—'}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      final repo = ref.read(extendedServicesRepositoryProvider);
                      if (v == 'test') {
                        await guard(() async {
                          await repo.testAutomation(a.id);
                          if (mounted) await _snack(context, l10n.integrationsTestQueued);
                        });
                      } else if (v == 'delete') {
                        final ok = await confirmRiskyAction(
                          context,
                          title: l10n.integrationsDeleteAutomationTitle,
                          body: l10n.integrationsDeleteAutomationBody(a.name),
                          confirmLabel: l10n.actionDelete,
                        );
                        if (ok != true) return;
                        await guard(() async {
                          await repo.deleteAutomation(a.id);
                          await _reload();
                        });
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'test', child: Text(l10n.integrationsRunTest)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.integrationsDelete)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ParkingFamilyScreen extends ConsumerStatefulWidget {
  const ParkingFamilyScreen({super.key});

  @override
  ConsumerState<ParkingFamilyScreen> createState() => _ParkingFamilyScreenState();
}

class _ParkingFamilyScreenState extends ConsumerState<ParkingFamilyScreen> with _FamilyLoader {
  ParkingStatusState? _status;
  List<ParkingSessionEntry> _sessions = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await guard(() async {
      final repo = ref.read(extendedServicesRepositoryProvider);
      final status = await repo.fetchParkingStatus();
      final sessions = await repo.listParkingSessions();
      setState(() {
        _status = status;
        _sessions = sessions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = _status;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.integrationsParkingTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            if (status != null)
              SwitchListTile(
                title: Text(l10n.integrationsParkingEnabled),
                value: status.enabled ?? false,
                onChanged: busy
                    ? null
                    : (v) => guard(() async {
                          await ref.read(extendedServicesRepositoryProvider).saveParkingConfig(enabled: v);
                          await _reload();
                        }),
              ),
            for (final s in _sessions)
              ListTile(
                title: Text(s.place ?? s.id),
                subtitle: Text(s.startedAt ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await confirmRiskyAction(
                      context,
                      title: l10n.integrationsDeleteSessionTitle,
                      body: l10n.integrationsDeleteSessionBody,
                      confirmLabel: l10n.actionDelete,
                    );
                    if (ok != true) return;
                    await guard(() async {
                      await ref.read(extendedServicesRepositoryProvider).deleteParkingSession(s.id);
                      await _reload();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TripsFamilyScreen extends ConsumerStatefulWidget {
  const TripsFamilyScreen({super.key});

  @override
  ConsumerState<TripsFamilyScreen> createState() => _TripsFamilyScreenState();
}

class _TripsFamilyScreenState extends ConsumerState<TripsFamilyScreen> with _FamilyLoader {
  List<TripEntry> _trips = const [];
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await guard(() async {
      final repo = ref.read(extendedServicesRepositoryProvider);
      final trips = await repo.listTrips();
      final summary = await repo.fetchTripSummary();
      setState(() {
        _trips = trips;
        _summary = summary;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalKm = _summary?['totalKm'];
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.integrationsTripsTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            if (totalKm != null)
              ListTile(
                title: Text(l10n.integrationsTripSummary),
                subtitle: Text(l10n.integrationsTripTotalKm(totalKm.toString())),
              ),
            for (final t in _trips)
              ListTile(
                title: Text(t.label ?? t.id),
                subtitle: Text('${t.distanceKm ?? '—'} km · ${t.startedAt ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await confirmRiskyAction(
                      context,
                      title: l10n.integrationsDeleteTripTitle,
                      body: l10n.integrationsDeleteTripBody,
                      confirmLabel: l10n.actionDelete,
                    );
                    if (ok != true) return;
                    await guard(() async {
                      await ref.read(extendedServicesRepositoryProvider).deleteTrip(t.id);
                      await _reload();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AudioLibraryFamilyScreen extends ConsumerStatefulWidget {
  const AudioLibraryFamilyScreen({super.key});

  @override
  ConsumerState<AudioLibraryFamilyScreen> createState() => _AudioLibraryFamilyScreenState();
}

class _AudioLibraryFamilyScreenState extends ConsumerState<AudioLibraryFamilyScreen>
    with _FamilyLoader {
  List<AudioLibraryEntry> _clips = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await guard(() async {
      final list = await ref.read(extendedServicesRepositoryProvider).listAudioLibrary();
      setState(() => _clips = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.integrationsAudioTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.tonal(
                onPressed: busy
                    ? null
                    : () => guard(() async {
                          await ref.read(extendedServicesRepositoryProvider).stopAudioPlayback();
                          if (mounted) await _snack(context, l10n.integrationsAudioStopped);
                        }),
                child: Text(l10n.integrationsAudioStopAll),
              ),
            ),
            for (final c in _clips)
              ListTile(
                title: Text(c.name),
                subtitle: c.sizeBytes != null ? Text('${c.sizeBytes} B') : null,
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => guard(() async {
                    await ref.read(extendedServicesRepositoryProvider).playAudioClip(c.name);
                    if (mounted) await _snack(context, l10n.integrationsAudioPlayQueued(c.name));
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GenAiToolsFamilyScreen extends ConsumerStatefulWidget {
  const GenAiToolsFamilyScreen({super.key});

  @override
  ConsumerState<GenAiToolsFamilyScreen> createState() => _GenAiToolsFamilyScreenState();
}

class _GenAiToolsFamilyScreenState extends ConsumerState<GenAiToolsFamilyScreen> with _FamilyLoader {
  GenAiRoutinesState? _routines;
  List<GenAiIncidentPack> _incidents = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await guard(() async {
      final repo = ref.read(extendedServicesRepositoryProvider);
      final routines = await repo.fetchGenAiRoutines();
      final incidents = await repo.listGenAiIncidents();
      setState(() {
        _routines = routines;
        _incidents = incidents;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final routines = _routines;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.integrationsGenAiToolsTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            if (routines != null)
              SwitchListTile(
                title: Text(l10n.integrationsGenAiRoutines),
                subtitle: Text(routines.pendingSuggestions.join(', ')),
                value: routines.enabled ?? false,
                onChanged: busy
                    ? null
                    : (v) => guard(() async {
                          await ref.read(extendedServicesRepositoryProvider).saveGenAiRoutinesConfig(enabled: v);
                          await _reload();
                        }),
              ),
            ListTile(
              title: Text(l10n.integrationsGenAiActionExecute),
              subtitle: Text(l10n.integrationsGenAiActionExecuteHint),
              trailing: FilledButton(
                onPressed: busy
                    ? null
                    : () => guard(() async {
                          await ref.read(extendedServicesRepositoryProvider).executeGenAiAction({
                            'type': 'vehicle.flash_lights',
                            'params': <String, dynamic>{},
                          });
                          if (mounted) await _snack(context, l10n.integrationsActionQueued);
                        }),
                child: Text(l10n.integrationsExecute),
              ),
            ),
            const Divider(),
            for (final pack in _incidents)
              ListTile(
                title: Text(pack.title ?? pack.id),
                subtitle: Text(pack.createdAt ?? ''),
              ),
          ],
        ),
      ),
    );
  }
}

class TelegramFamilyScreen extends ConsumerStatefulWidget {
  const TelegramFamilyScreen({super.key});

  @override
  ConsumerState<TelegramFamilyScreen> createState() => _TelegramFamilyScreenState();
}

class _TelegramFamilyScreenState extends ConsumerState<TelegramFamilyScreen> with _FamilyLoader {
  TelegramStatusState? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await guard(() async {
      final status = await ref.read(extendedServicesRepositoryProvider).fetchTelegramStatus();
      setState(() => _status = status);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = _status;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.integrationsTelegramTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            if (status != null) ...[
              ListTile(
                title: Text(l10n.integrationsTelegramBot),
                subtitle: Text(status.botUsername ?? l10n.integrationsNotConfigured),
              ),
              SwitchListTile(
                title: Text(l10n.integrationsTelegramVideoUploads),
                value: status.videoUploads ?? false,
                onChanged: busy
                    ? null
                    : (v) => guard(() async {
                          await ref
                              .read(extendedServicesRepositoryProvider)
                              .saveTelegramPreferences(videoUploads: v);
                          await _reload();
                        }),
              ),
              ListTile(
                title: Text(l10n.integrationsTelegramClearPairing),
                subtitle: Text(l10n.integrationsTelegramClearHint),
                onTap: () async {
                  final ok = await confirmRiskyAction(
                    context,
                    title: l10n.integrationsTelegramClearTitle,
                    body: l10n.integrationsTelegramClearBody,
                    confirmLabel: l10n.actionConfirm,
                  );
                  if (ok != true) return;
                  await guard(() async {
                    await ref.read(extendedServicesRepositoryProvider).clearTelegramOwner();
                    await _reload();
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PlatformConnectorsScreen extends ConsumerStatefulWidget {
  const PlatformConnectorsScreen({super.key});

  @override
  ConsumerState<PlatformConnectorsScreen> createState() => _PlatformConnectorsScreenState();
}

class _PlatformConnectorsScreenState extends ConsumerState<PlatformConnectorsScreen>
    with _FamilyLoader {
  Map<String, dynamic> _cards = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await guard(() async {
      final repo = ref.read(extendedServicesRepositoryProvider);
      final data = <String, dynamic>{
        'abrp': await repo.fetchAbrpStatus(),
        'mqtt': await repo.fetchMqttStatus(),
        'launcher': await repo.fetchLauncherSummary(),
        'roadsense': await repo.fetchRoadSenseHazards(),
        'bydcloud': await repo.fetchBydCloudStatus(),
        'community': await repo.listCommunityAutomations(),
      };
      setState(() => _cards = data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.integrationsPlatformTitle)),
        floatingActionButton: FloatingActionButton(onPressed: busy ? null : _reload, child: const Icon(Icons.refresh)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            _PlatformCard(title: 'ABRP', body: _cards['abrp']?.toString() ?? '—'),
            _PlatformCard(title: 'MQTT', body: _cards['mqtt']?.toString() ?? '—'),
            _PlatformCard(title: l10n.integrationsLauncherTitle, body: _cards['launcher']?.toString() ?? '—'),
            _PlatformCard(title: 'RoadSense', body: _cards['roadsense']?.toString() ?? '—'),
            _PlatformCard(title: l10n.integrationsBydCloudTitle, body: _cards['bydcloud']?.toString() ?? '—'),
            _PlatformCard(title: l10n.integrationsCommunityTitle, body: _cards['community']?.toString() ?? '—'),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.integrationsHeadUnitNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
