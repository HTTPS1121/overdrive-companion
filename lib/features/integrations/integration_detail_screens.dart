import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/format_helpers.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../core/widgets/key_value_readout_card.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/extended_services_models.dart';
import '../../providers/app_providers.dart';
import 'integrations_loader.dart';

class AutomationSettingsScreen extends ConsumerStatefulWidget {
  const AutomationSettingsScreen({super.key});

  @override
  ConsumerState<AutomationSettingsScreen> createState() => _AutomationSettingsScreenState();
}

class _AutomationSettingsScreenState extends ConsumerState<AutomationSettingsScreen>
    with FamilyLoaderMixin {
  Map<String, dynamic>? _settings;
  Map<String, dynamic>? _state;
  Map<String, dynamic>? _schema;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await guard(() async {
      final repo = ref.read(extendedServicesRepositoryProvider);
      final settings = await repo.fetchAutomationSettings();
      final state = await repo.fetchAutomationState();
      final schema = await repo.fetchAutomationSchema();
      setState(() {
        _settings = settings;
        _state = state;
        _schema = schema;
      });
    });
  }

  Future<void> _save(bool? globalEnabled) async {
    final body = <String, dynamic>{...?_settings};
    if (globalEnabled != null) body['globalEnabled'] = globalEnabled;
    await guard(() async {
      await ref.read(extendedServicesRepositoryProvider).saveAutomationSettings(body);
      await _reload();
      if (mounted) await integrationSnack(context, context.l10n.integrationsSaved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final globalEnabled = _settings?['globalEnabled'] == true || _settings?['enabled'] == true;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.automationSettingsTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            if (_schema != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: KeyValueReadoutCard(
                  title: l10n.automationSchemaTitle,
                  rows: [
                    MapEntry(l10n.automationLabelSchemaVersion, '${_schema!['schemaVersion'] ?? '—'}'),
                    MapEntry(
                      l10n.automationLabelSignals,
                      (_schema!['signals'] is List) ? (_schema!['signals'] as List).join(', ') : '—',
                    ),
                  ],
                ),
              ),
            SwitchListTile(
              title: Text(l10n.automationGlobalEnabled),
              value: globalEnabled,
              onChanged: busy ? null : (v) => _save(v),
            ),
            if (_state != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: KeyValueReadoutCard(title: l10n.automationStateTitle, rows: [
                  if (_state!['engine'] != null)
                    MapEntry(l10n.automationLabelEngineState, _state!['engine']?.toString() ?? '—'),
                  if (_state!['activeCount'] != null)
                    MapEntry(l10n.automationStateTitle, _state!['activeCount']?.toString() ?? '—'),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

class AutomationEditScreen extends ConsumerStatefulWidget {
  const AutomationEditScreen({super.key, required this.entry});

  final AutomationEntry entry;

  @override
  ConsumerState<AutomationEditScreen> createState() => _AutomationEditScreenState();
}

class _AutomationEditScreenState extends ConsumerState<AutomationEditScreen> with FamilyLoaderMixin {
  late final TextEditingController _nameCtrl;
  String _mode = 'manual';
  bool _enabled = true;
  List<String> _signals = const [];
  final List<_RuleRow> _rules = [];
  final List<_ActionRow> _actions = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.entry.name);
    _mode = widget.entry.mode ?? 'manual';
    _enabled = widget.entry.enabled ?? true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSchema());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final r in _rules) {
      r.dispose();
    }
    for (final a in _actions) {
      a.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSchema() async {
    await guard(() async {
      final schema = await ref.read(extendedServicesRepositoryProvider).fetchAutomationSchema();
      final raw = schema['signals'];
      setState(() {
        _signals = raw is List ? raw.map((e) => e.toString()).toList() : const [];
        if (_rules.isEmpty) _rules.add(_RuleRow(signal: _signals.isNotEmpty ? _signals.first : ''));
        if (_actions.isEmpty) _actions.add(_ActionRow());
      });
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      await integrationSnack(context, l10n.integrationsNameRequired);
      return;
    }
    final rules = [
      for (final r in _rules)
        {
          'signal': r.signal,
          'op': r.op,
          'value': num.tryParse(r.valueCtrl.text.trim()) ?? r.valueCtrl.text.trim(),
        },
    ];
    final actions = [
      for (final a in _actions)
        {
          'type': a.typeCtrl.text.trim(),
          if (a.targetCtrl.text.trim().isNotEmpty) 'target': a.targetCtrl.text.trim(),
          if (a.valueCtrl.text.trim().isNotEmpty)
            'value': num.tryParse(a.valueCtrl.text.trim()) ?? a.valueCtrl.text.trim(),
        },
    ];
    await guard(() async {
      await ref.read(extendedServicesRepositoryProvider).updateAutomation(
            widget.entry.id,
            name: name,
            enabled: _enabled,
            mode: _mode,
            rules: rules,
            actions: actions,
          );
      if (mounted) {
        await integrationSnack(context, l10n.integrationsSaved);
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.automationEditTitle)),
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
            SwitchListTile(title: Text(l10n.automationEnabledLabel), value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: InputDecoration(labelText: l10n.automationModeLabel),
              items: [
                DropdownMenuItem(value: 'automatic', child: Text(l10n.integrationsAutomationModeAutomatic)),
                DropdownMenuItem(value: 'manual', child: Text(l10n.integrationsAutomationModeManual)),
              ],
              onChanged: busy ? null : (v) => setState(() => _mode = v ?? _mode),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.automationRulesSection, style: Theme.of(context).textTheme.titleMedium),
            ),
            for (var i = 0; i < _rules.length; i++)
              _RuleEditor(
                row: _rules[i],
                signals: _signals,
                onRemove: _rules.length > 1 ? () => setState(() => _rules.removeAt(i)) : null,
              ),
            TextButton.icon(
              onPressed: () => setState(() => _rules.add(_RuleRow(signal: _signals.isNotEmpty ? _signals.first : ''))),
              icon: const Icon(Icons.add),
              label: Text(l10n.automationAddRule),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.automationActionsSection, style: Theme.of(context).textTheme.titleMedium),
            ),
            for (var i = 0; i < _actions.length; i++)
              _ActionEditor(
                row: _actions[i],
                onRemove: _actions.length > 1 ? () => setState(() => _actions.removeAt(i)) : null,
              ),
            TextButton.icon(
              onPressed: () => setState(() => _actions.add(_ActionRow())),
              icon: const Icon(Icons.add),
              label: Text(l10n.automationAddAction),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(onPressed: busy ? null : _save, child: Text(l10n.platformSave)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow {
  _RuleRow({required this.signal, this.op = 'eq'});
  String signal;
  String op;
  final valueCtrl = TextEditingController();

  void dispose() => valueCtrl.dispose();
}

class _ActionRow {
  final typeCtrl = TextEditingController();
  final targetCtrl = TextEditingController();
  final valueCtrl = TextEditingController();

  void dispose() {
    typeCtrl.dispose();
    targetCtrl.dispose();
    valueCtrl.dispose();
  }
}

class _RuleEditor extends StatelessWidget {
  const _RuleEditor({required this.row, required this.signals, this.onRemove});

  final _RuleRow row;
  final List<String> signals;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: signals.contains(row.signal) ? row.signal : (signals.isNotEmpty ? signals.first : null),
              decoration: InputDecoration(labelText: l10n.automationSignalLabel),
              items: [
                for (final s in signals) DropdownMenuItem(value: s, child: Text(s)),
              ],
              onChanged: (v) {
                if (v != null) row.signal = v;
              },
            ),
            DropdownButtonFormField<String>(
              value: row.op,
              decoration: InputDecoration(labelText: l10n.automationOpLabel),
              items: const [
                DropdownMenuItem(value: 'eq', child: Text('=')),
                DropdownMenuItem(value: 'gt', child: Text('>')),
                DropdownMenuItem(value: 'lt', child: Text('<')),
              ],
              onChanged: (v) {
                if (v != null) row.op = v;
              },
            ),
            TextField(
              controller: row.valueCtrl,
              decoration: InputDecoration(labelText: l10n.automationValueLabel),
            ),
            if (onRemove != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionEditor extends StatelessWidget {
  const _ActionEditor({required this.row, this.onRemove});

  final _ActionRow row;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: row.typeCtrl,
              decoration: InputDecoration(labelText: l10n.genAiActionTypeLabel),
            ),
            TextField(
              controller: row.targetCtrl,
              decoration: InputDecoration(labelText: l10n.genAiActionTargetLabel),
            ),
            TextField(
              controller: row.valueCtrl,
              decoration: InputDecoration(labelText: l10n.genAiActionValueLabel),
            ),
            if (onRemove != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline)),
              ),
          ],
        ),
      ),
    );
  }
}

class ParkingSignageScreen extends ConsumerStatefulWidget {
  const ParkingSignageScreen({super.key, required this.sessionId, this.placeLabel});

  final String sessionId;
  final String? placeLabel;

  @override
  ConsumerState<ParkingSignageScreen> createState() => _ParkingSignageScreenState();
}

class _ParkingSignageScreenState extends ConsumerState<ParkingSignageScreen> with FamilyLoaderMixin {
  final _messageCtrl = TextEditingController();
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await guard(() async {
      final json =
          await ref.read(extendedServicesRepositoryProvider).fetchParkingSignage(widget.sessionId);
      setState(() {
        _messageCtrl.text = json['message']?.toString() ?? '';
        _enabled = json['enabled'] != false;
      });
    });
  }

  Future<void> _save() async {
    await guard(() async {
      await ref.read(extendedServicesRepositoryProvider).saveParkingSignage(
            widget.sessionId,
            message: _messageCtrl.text.trim(),
            enabled: _enabled,
          );
      if (mounted) await integrationSnack(context, context.l10n.integrationsSaved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.parkingSignageTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            ListTile(
              title: Text(widget.placeLabel ?? widget.sessionId),
              subtitle: Text(widget.sessionId),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _messageCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.parkingSignageMessageLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.parkingSignageEnabled),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(onPressed: busy ? null : _save, child: Text(l10n.platformSave)),
            ),
          ],
        ),
      ),
    );
  }
}

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.entry});

  final TripEntry entry;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> with FamilyLoaderMixin {
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await guard(() async {
      final json = await ref.read(extendedServicesRepositoryProvider).fetchTripDetail(widget.entry.id);
      setState(() => _detail = json);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = _detail;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.entry.label ?? widget.entry.id)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            ListTile(
              title: Text(l10n.integrationsTripSummary),
              subtitle: Text('${widget.entry.distanceKm ?? d?['distanceKm'] ?? '—'} km'),
            ),
            ListTile(
              title: Text(l10n.tripStartedLabel),
              subtitle: Text(formatVehicleTimestamp(context, widget.entry.startedAt ?? d?['startedAt']?.toString())),
            ),
            if (d != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: KeyValueReadoutCard(
                  title: l10n.tripDetailTitle,
                  rows: [
                    for (final e in d!.entries)
                      if (e.value is! Map && e.value is! List)
                        MapEntry(e.key.toString(), e.value?.toString() ?? '—'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
