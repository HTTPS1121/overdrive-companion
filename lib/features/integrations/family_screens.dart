import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/format_helpers.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/extended_services_models.dart';
import '../../providers/app_providers.dart';
import 'integration_detail_screens.dart';
import 'integrations_loader.dart';

Future<void> _snack(BuildContext context, String text) => integrationSnack(context, text);

String _automationModeLabel(dynamic l10n, String? mode) => switch (mode) {
      'automatic' => l10n.integrationsAutomationModeAutomatic,
      'manual' => l10n.integrationsAutomationModeManual,
      _ => mode ?? '—',
    };


class AutomationsFamilyScreen extends ConsumerStatefulWidget {
  const AutomationsFamilyScreen({super.key});

  @override
  ConsumerState<AutomationsFamilyScreen> createState() => _AutomationsFamilyScreenState();
}

class _AutomationsFamilyScreenState extends ConsumerState<AutomationsFamilyScreen>
    with FamilyLoaderMixin {
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
        appBar: AppBar(
          title: Text(l10n.integrationsAutomationsTitle),
          actions: [
            IconButton(
              tooltip: l10n.automationSettingsTitle,
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AutomationSettingsScreen()),
              ),
            ),
          ],
        ),
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
                  subtitle: Text('${a.id} · ${_automationModeLabel(l10n, a.mode)}'),
                  onTap: busy
                      ? null
                      : () async {
                          final changed = await Navigator.of(context).push<bool>(
                            MaterialPageRoute<bool>(builder: (_) => AutomationEditScreen(entry: a)),
                          );
                          if (changed == true) await _reload();
                        },
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

class _ParkingFamilyScreenState extends ConsumerState<ParkingFamilyScreen> with FamilyLoaderMixin {
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
            if (status == null && busy)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (status != null)
              Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SwitchListTile(
                  title: Text(l10n.integrationsParkingEnabled),
                  value: status.enabled ?? false,
                  onChanged: busy
                      ? null
                      : (v) => guard(() async {
                            await ref.read(extendedServicesRepositoryProvider).saveParkingConfig(enabled: v);
                            await _reload();
                          }),
                ),
              ),
            if (status != null && _sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.integrationsEmptyParkingSessions, textAlign: TextAlign.center),
              ),
            for (final s in _sessions)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                title: Text(s.place ?? s.id),
                subtitle: Text(formatVehicleTimestamp(context, s.startedAt)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ParkingSignageScreen(sessionId: s.id, placeLabel: s.place),
                  ),
                ),
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

class _TripsFamilyScreenState extends ConsumerState<TripsFamilyScreen> with FamilyLoaderMixin {
  List<TripEntry> _trips = const [];
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _config;
  final _historyDaysCtrl = TextEditingController(text: '14');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _historyDaysCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await guard(() async {
      final repo = ref.read(extendedServicesRepositoryProvider);
      final trips = await repo.listTrips();
      final summary = await repo.fetchTripSummary();
      final config = await repo.fetchTripConfig();
      setState(() {
        _trips = trips;
        _summary = summary;
        _config = config;
        final days = config['historyDays'];
        if (days is num) _historyDaysCtrl.text = days.toInt().toString();
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
            if (_summary == null && busy)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (totalKm != null)
              Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ListTile(
                  title: Text(l10n.integrationsTripSummary),
                  subtitle: Text(l10n.integrationsTripTotalKm(totalKm.toString())),
                ),
              ),
            if (_config != null)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.tripConfigTitle, style: Theme.of(context).textTheme.titleSmall),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.tripConfigEnabled),
                        value: _config!['enabled'] == true,
                        onChanged: busy
                            ? null
                            : (v) => guard(() async {
                                  final days = int.tryParse(_historyDaysCtrl.text.trim()) ?? 14;
                                  await ref
                                      .read(extendedServicesRepositoryProvider)
                                      .saveTripConfig(enabled: v, historyDays: days);
                                  await _reload();
                                }),
                      ),
                      TextField(
                        controller: _historyDaysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.tripHistoryDaysLabel),
                      ),
                      FilledButton.tonal(
                        onPressed: busy
                            ? null
                            : () async {
                                final ok = await confirmRiskyAction(
                                  context,
                                  title: l10n.tripBootstrapTitle,
                                  body: l10n.tripBootstrapBody,
                                  confirmLabel: l10n.actionConfirm,
                                );
                                if (ok != true) return;
                                await guard(() async {
                                  await ref.read(extendedServicesRepositoryProvider).bootstrapTrips();
                                  await _reload();
                                  if (mounted) await _snack(context, l10n.integrationsSaved);
                                });
                              },
                        child: Text(l10n.tripBootstrapTitle),
                      ),
                    ],
                  ),
                ),
              ),
            if (_trips.isEmpty && _summary != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.integrationsEmptyTrips, textAlign: TextAlign.center),
              ),
            for (final t in _trips)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                title: Text(t.label ?? t.id),
                subtitle: Text(
                  '${t.distanceKm ?? '—'} km · ${formatVehicleTimestamp(context, t.startedAt)}',
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => TripDetailScreen(entry: t)),
                ),
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
    with FamilyLoaderMixin {
  List<AudioLibraryEntry> _clips = const [];
  Map<String, dynamic>? _avas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await guard(() async {
      final repo = ref.read(extendedServicesRepositoryProvider);
      final list = await repo.listAudioLibrary();
      final avas = await repo.fetchAudioAvasState();
      setState(() {
        _clips = list;
        _avas = avas;
      });
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
            if (_avas != null)
              Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: ListTile(
                  title: Text(l10n.audioAvasTitle),
                  subtitle: Text(
                    _avas!['playing'] == true ? l10n.audioAvasPlaying : l10n.audioAvasIdle,
                  ),
                ),
              ),
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
                subtitle: c.sizeBytes != null ? Text(formatByteCount(context, c.sizeBytes)) : null,
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

class _GenAiToolsFamilyScreenState extends ConsumerState<GenAiToolsFamilyScreen> with FamilyLoaderMixin {
  GenAiRoutinesState? _routines;
  List<GenAiIncidentPack> _incidents = const [];
  final _actionTypeCtrl = TextEditingController();
  final _actionTargetCtrl = TextEditingController();
  final _actionValueCtrl = TextEditingController();
  final _recordingIdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _actionTypeCtrl.dispose();
    _actionTargetCtrl.dispose();
    _actionValueCtrl.dispose();
    _recordingIdCtrl.dispose();
    super.dispose();
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

  Future<void> _executeAction() async {
    final l10n = context.l10n;
    final type = _actionTypeCtrl.text.trim();
    if (type.isEmpty) {
      await _snack(context, l10n.integrationsNameRequired);
      return;
    }
    final action = <String, dynamic>{
      'type': type,
      if (_actionTargetCtrl.text.trim().isNotEmpty) 'target': _actionTargetCtrl.text.trim(),
      if (_actionValueCtrl.text.trim().isNotEmpty)
        'value': num.tryParse(_actionValueCtrl.text.trim()) ?? _actionValueCtrl.text.trim(),
    };
    await guard(() async {
      await ref.read(extendedServicesRepositoryProvider).executeGenAiAction(action);
      if (mounted) await _snack(context, l10n.integrationsActionQueued);
    });
  }

  Future<void> _createIncident() async {
    final l10n = context.l10n;
    final id = _recordingIdCtrl.text.trim();
    if (id.isEmpty) {
      await _snack(context, l10n.genAiRecordingIdRequired);
      return;
    }
    final ok = await confirmRiskyAction(
      context,
      title: l10n.genAiCreateIncidentTitle,
      body: l10n.genAiCreateIncidentBody,
      confirmLabel: l10n.actionConfirm,
    );
    if (ok != true) return;
    await guard(() async {
      await ref.read(extendedServicesRepositoryProvider).createGenAiIncident(recordingId: id);
      await _reload();
      if (mounted) await _snack(context, l10n.integrationsSaved);
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
                subtitle: Text(
                  routines.pendingSuggestionLabels.isEmpty
                      ? l10n.integrationsEmptyList
                      : routines.pendingSuggestionLabels.join(', '),
                ),
                value: routines.enabled ?? false,
                onChanged: busy
                    ? null
                    : (v) => guard(() async {
                          await ref.read(extendedServicesRepositoryProvider).saveGenAiRoutinesConfig(enabled: v);
                          await _reload();
                        }),
              ),
            if (routines != null)
              for (final s in routines.suggestions)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(s.title ?? s.id),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        FilledButton.tonal(
                          onPressed: busy
                              ? null
                              : () => guard(() async {
                                    await ref
                                        .read(extendedServicesRepositoryProvider)
                                        .decideGenAiRoutine(s.id, true);
                                    await _reload();
                                  }),
                          child: Text(l10n.genAiRoutineAccept),
                        ),
                        OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => guard(() async {
                                    await ref
                                        .read(extendedServicesRepositoryProvider)
                                        .decideGenAiRoutine(s.id, false);
                                    await _reload();
                                  }),
                          child: Text(l10n.genAiRoutineReject),
                        ),
                      ],
                    ),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(l10n.integrationsGenAiActionExecute, style: Theme.of(context).textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l10n.integrationsGenAiActionExecuteHint, style: Theme.of(context).textTheme.bodySmall),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _actionTypeCtrl,
                    decoration: InputDecoration(labelText: l10n.genAiActionTypeLabel),
                  ),
                  TextField(
                    controller: _actionTargetCtrl,
                    decoration: InputDecoration(labelText: l10n.genAiActionTargetLabel),
                  ),
                  TextField(
                    controller: _actionValueCtrl,
                    decoration: InputDecoration(labelText: l10n.genAiActionValueLabel),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: busy ? null : _executeAction, child: Text(l10n.integrationsExecute)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(l10n.genAiCreateIncidentTitle, style: Theme.of(context).textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _recordingIdCtrl,
                decoration: InputDecoration(labelText: l10n.genAiRecordingIdLabel),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.tonal(onPressed: busy ? null : _createIncident, child: Text(l10n.genAiCreateIncidentTitle)),
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

class _TelegramFamilyScreenState extends ConsumerState<TelegramFamilyScreen> with FamilyLoaderMixin {
  TelegramStatusState? _status;
  final _pinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
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
            if (status == null && busy)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (status != null) ...[
              Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: ListTile(
                  title: Text(l10n.integrationsTelegramBot),
                  subtitle: Text(status.botUsername ?? l10n.integrationsNotConfigured),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SwitchListTile(
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
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.telegramPinTitle, style: Theme.of(context).textTheme.titleSmall),
                      TextField(
                        controller: _pinCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: l10n.telegramPinLabel,
                          counterText: '',
                        ),
                      ),
                      FilledButton(
                        onPressed: busy || _pinCtrl.text.trim().length < 4
                            ? null
                            : () => guard(() async {
                                  await ref
                                      .read(extendedServicesRepositoryProvider)
                                      .submitTelegramPin(_pinCtrl.text.trim());
                                  _pinCtrl.clear();
                                  await _reload();
                                  if (mounted) await _snack(context, l10n.integrationsSaved);
                                }),
                        child: Text(l10n.telegramPinSubmit),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
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
    with FamilyLoaderMixin {
  Map<String, dynamic>? _abrpConfig;
  Map<String, dynamic>? _mqttConnections;
  Map<String, dynamic>? _launcherSummary;
  Map<String, dynamic>? _launcherAppearance;
  Map<String, dynamic>? _bydCloud;
  Map<String, dynamic>? _mqttTelemetry;
  List<dynamic> _community = const [];
  final _abrpEnabled = ValueNotifier(true);
  final _mqttNameCtrl = TextEditingController(text: 'Home broker');
  final _mqttHostCtrl = TextEditingController(text: 'mqtt.local');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _mqttNameCtrl.dispose();
    _mqttHostCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await guard(() async {
      final repo = ref.read(extendedServicesRepositoryProvider);
      _abrpConfig = await repo.fetchAbrpConfig();
      _mqttConnections = await repo.listMqttConnections();
      _launcherSummary = await repo.fetchLauncherSummary();
      _launcherAppearance = await repo.fetchLauncherAppearance();
      _bydCloud = await repo.fetchBydCloudStatus();
      _mqttTelemetry = await repo.fetchMqttTelemetry();
      final community = await repo.listCommunityAutomations();
      final items = community['items'];
      setState(() {
        _community = items is List ? items : const [];
        _abrpEnabled.value = _abrpConfig?['enabled'] == true;
      });
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
            Text(l10n.platformDestructiveWarning, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(l10n.platformAbrpTitle, style: Theme.of(context).textTheme.titleMedium),
            ValueListenableBuilder<bool>(
              valueListenable: _abrpEnabled,
              builder: (_, v, __) => SwitchListTile(
                title: const Text('enabled'),
                value: v,
                onChanged: busy ? null : (nv) => _abrpEnabled.value = nv,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => guard(() async {
                          await ref.read(extendedServicesRepositoryProvider).saveAbrpConfig({
                            'enabled': _abrpEnabled.value,
                            'mirrorSoc': true,
                          });
                          if (mounted) await _snack(context, l10n.integrationsSaved);
                          await _reload();
                        }),
                child: Text(l10n.platformSave),
              ),
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      final ok = await confirmRiskyAction(
                        context,
                        title: l10n.platformDeleteToken,
                        body: l10n.platformDestructiveWarning,
                        confirmLabel: l10n.actionDelete,
                      );
                      if (ok != true) return;
                      await guard(() async {
                        await ref.read(extendedServicesRepositoryProvider).deleteAbrpToken();
                        await _reload();
                      });
                    },
              child: Text(l10n.platformDeleteToken),
            ),
            const Divider(),
            Text(l10n.platformMqttTitle, style: Theme.of(context).textTheme.titleMedium),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(controller: _mqttNameCtrl, decoration: const InputDecoration(labelText: 'name')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(controller: _mqttHostCtrl, decoration: const InputDecoration(labelText: 'host')),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => guard(() async {
                          await ref.read(extendedServicesRepositoryProvider).addMqttConnection({
                            'name': _mqttNameCtrl.text.trim(),
                            'host': _mqttHostCtrl.text.trim(),
                            'enabled': true,
                          });
                          if (mounted) await _snack(context, l10n.integrationsSaved);
                          await _reload();
                        }),
                child: Text(l10n.platformMqttAdd),
              ),
            ),
            if (_mqttConnections?['connections'] is List)
              for (final c in _mqttConnections!['connections'] as List)
                ListTile(
                  title: Text(c is Map ? (c['name']?.toString() ?? '') : c.toString()),
                  subtitle: Text(c is Map ? (c['host']?.toString() ?? c['id']?.toString() ?? '') : ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final id = c is Map ? c['id']?.toString() : null;
                      if (id == null) return;
                      await guard(() async {
                        await ref.read(extendedServicesRepositoryProvider).deleteMqttConnection(id);
                        await _reload();
                      });
                    },
                  ),
                ),
            const Divider(),
            Text(l10n.integrationsLauncherTitle, style: Theme.of(context).textTheme.titleMedium),
            if (_launcherSummary != null)
              ListTile(
                title: Text(l10n.integrationsLauncherTitle),
                subtitle: Text(_launcherSummary!['vehicle']?.toString() ?? l10n.integrationsNotConfigured),
              ),
            if (_launcherAppearance != null)
              ListTile(
                title: Text(l10n.launcherAppearanceTitle),
                subtitle: Text(
                  '${_launcherAppearance!['theme'] ?? '—'} · ${_launcherAppearance!['locale'] ?? '—'}',
                ),
              ),
            const Divider(),
            Text(l10n.integrationsBydCloudTitle, style: Theme.of(context).textTheme.titleMedium),
            if (_bydCloud != null)
              ListTile(
                title: Text(l10n.integrationsBydCloudTitle),
                subtitle: Text(
                  _bydCloud!['loggedIn'] == true
                      ? l10n.bydCloudLoggedIn
                      : (_bydCloud!['configured'] == true ? l10n.bydCloudConfigured : l10n.integrationsNotConfigured),
                ),
              ),
            const Divider(),
            Text(l10n.mqttTelemetryTitle, style: Theme.of(context).textTheme.titleMedium),
            if (_mqttTelemetry != null)
              ListTile(
                title: Text(l10n.mqttTelemetryTitle),
                subtitle: Text(
                  'SOC ${_mqttTelemetry!['soc'] ?? '—'} · ${formatVehicleTimestamp(context, _mqttTelemetry!['timestamp']?.toString())}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: busy
                      ? null
                      : () => guard(() async {
                            final t = await ref.read(extendedServicesRepositoryProvider).fetchMqttTelemetry();
                            setState(() => _mqttTelemetry = t);
                          }),
                ),
              ),
            const Divider(),
            Text(l10n.integrationsCommunityTitle, style: Theme.of(context).textTheme.titleMedium),
            for (final item in _community)
              ListTile(
                title: Text(item is Map ? (item['name']?.toString() ?? '') : item.toString()),
                subtitle: Text(item is Map ? '★ ${item['stars']}' : ''),
                trailing: FilledButton.tonal(
                  onPressed: busy
                      ? null
                      : () => guard(() async {
                            final id = item is Map ? item['id']?.toString() : null;
                            if (id == null) return;
                            await ref.read(extendedServicesRepositoryProvider).importCommunityAutomation(id);
                            if (mounted) await _snack(context, l10n.platformCommunityImport);
                          }),
                  child: Text(l10n.platformCommunityImport),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.integrationsHeadUnitNote, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
