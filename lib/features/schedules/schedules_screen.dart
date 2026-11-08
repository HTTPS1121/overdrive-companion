import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/format/booking_labels.dart';
import '../../core/format/seat_levels.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/ltr_metric.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/remote_feature_models.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';

class SchedulesScreen extends StatelessWidget {
  const SchedulesScreen({super.key, this.embedded = false});

  /// When true, shown inside [ControlsHubScreen] (no extra scaffold).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: TabBar(
              tabs: [
                Tab(text: l10n.scheduleTabClimate),
                Tab(text: l10n.scheduleTabCharging),
              ],
            ),
          ),
          const Expanded(
            child: RequiresConnection(
              child: TabBarView(
                children: [
                  _ClimateScheduleTab(),
                  _ChargingScheduleTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClimateScheduleTab extends ConsumerStatefulWidget {
  const _ClimateScheduleTab();

  @override
  ConsumerState<_ClimateScheduleTab> createState() => _ClimateScheduleTabState();
}

class _ClimateScheduleTabState extends ConsumerState<_ClimateScheduleTab> {
  ClimateScheduleState? _state;
  bool _loading = true;
  String? _error;
  int _temp = 22;
  int _duration = 20;
  String? _bookingId;
  final _hoursCtrl = TextEditingController(text: '06');
  final _minsCtrl = TextEditingController(text: '30');

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _hoursCtrl.dispose();
    _minsCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await ref.read(vehicleRepositoryProvider).fetchClimateSchedule();
      setState(() {
        _state = s;
        final first = s.bookings.isNotEmpty ? s.bookings.first : null;
        _bookingId = first?.bookingId;
        _temp = first?.temp?.round() ?? 22;
        _duration = first?.durationMinutes ?? 20;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int _bookingEpoch() {
    final now = DateTime.now().add(const Duration(hours: 2));
    return now.millisecondsSinceEpoch ~/ 1000;
  }

  Future<void> _save() async {
    final body = {
      'action': _bookingId != null ? 'update' : 'create',
      'bookingTime': _bookingEpoch(),
      'temp': _temp,
      'durationMinutes': _duration,
      if (_bookingId != null) 'bookingId': _bookingId,
    };
    final r = await ref.read(vehicleRepositoryProvider).saveClimateSchedule(body);
    if (!mounted) return;
    _snack(r);
    if (r.success) await _reload();
  }

  Future<void> _delete() async {
    if (_bookingId == null) return;
    final r = await ref.read(vehicleRepositoryProvider).saveClimateSchedule({
      'action': 'delete',
      'bookingId': _bookingId,
    });
    if (!mounted) return;
    _snack(r);
    if (r.success) await _reload();
  }

  void _snack(CommandResult r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(context.l10n, actionLabel: context.l10n.actionScheduleClimate))),
    );
  }

  ClimateBooking? get _selectedBooking {
    final id = _bookingId;
    final bookings = _state?.bookings;
    if (id == null || bookings == null) return null;
    for (final b in bookings) {
      if (b.bookingId == id) return b;
    }
    return null;
  }

  void _selectForEdit(ClimateBooking b) {
    setState(() {
      _bookingId = b.bookingId;
      _temp = b.temp?.round() ?? _temp;
      _duration = b.durationMinutes ?? _duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final s = _state;
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (s == null || !s.success) {
      return Center(child: Text(l10n.scheduleInvalidResponse));
    }
    if (!s.supported) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.scheduleClimateUnsupported(s.reason ?? '—'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (s.bookingsUnavailable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.scheduleClimateListUnavailable(s.reason ?? '—'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: scrollBottomPadding(context),
      children: [
        Text(l10n.scheduleClimateTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (s.bookings.isEmpty)
          Text(l10n.scheduleClimateEmpty)
        else
          ...s.bookings.map(
            (b) => Card(
              child: ListTile(
                selected: _bookingId == b.bookingId,
                onTap: () => _selectForEdit(b),
                title: Text(formatClimateBookingWhen(b, l10n: l10n)),
                subtitle: Text(
                  '${celsiusLabel(l10n, b.temp ?? _temp)} · ${l10n.scheduleMinutesShort('${b.durationMinutes ?? 0}')}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.scheduleDeleteTooltip,
                      onPressed: () async {
                        _bookingId = b.bookingId;
                        await _delete();
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const Divider(height: 28),
        Text(
          climateEditorTitle(l10n, isNew: _bookingId == null, selected: _selectedBooking),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(celsiusLabel(l10n, _temp)),
        Slider(
          value: _temp.toDouble(),
          min: 15,
          max: 31,
          divisions: 16,
          label: celsiusLabel(l10n, _temp),
          onChanged: (v) => setState(() => _temp = v.round()),
        ),
        DropdownButtonFormField<int>(
          initialValue: _duration,
          decoration: InputDecoration(labelText: l10n.scheduleDurationMinutes),
          items: const [10, 15, 20, 25, 30]
              .map((m) => DropdownMenuItem(value: m, child: Text(l10n.scheduleMinutesShort('$m'))))
              .toList(),
          onChanged: (v) => setState(() => _duration = v ?? 20),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _save,
          child: Text(_bookingId == null ? l10n.scheduleCreate : l10n.scheduleUpdate),
        ),
        if (_bookingId != null)
          TextButton(
            onPressed: () => setState(() => _bookingId = null),
            child: Text(l10n.scheduleCancelEdit),
          ),
      ],
    );
  }
}

class _ChargingScheduleTab extends ConsumerStatefulWidget {
  const _ChargingScheduleTab();

  @override
  ConsumerState<_ChargingScheduleTab> createState() => _ChargingScheduleTabState();
}

class _ChargingScheduleTabState extends ConsumerState<_ChargingScheduleTab> {
  ChargingScheduleState? _state;
  bool _loading = true;
  String? _error;
  final _startCtrl = TextEditingController(text: '22:00');
  final _endCtrl = TextEditingController(text: '06:00');
  String _chargeWay = 'e';
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await ref.read(vehicleRepositoryProvider).fetchChargingSchedule();
      setState(() {
        _state = s;
        _enabled = s.enabled == true;
        if (s.startChargeTime != null && s.startChargeTime != 'null') {
          _startCtrl.text = s.startChargeTime!;
        }
        if (s.endChargeTime != null && s.endChargeTime != 'null') {
          _endCtrl.text = s.endChargeTime!;
        }
        _chargeWay = s.chargeWay ?? 'e';
        _loading = false;
      });
    } catch (e) {
      setState(() => _error = e.toString());
      setState(() => _loading = false);
    }
  }

  Future<void> _toggle(bool v) async {
    final r = await ref.read(vehicleRepositoryProvider).saveChargingSchedule({'enabled': v});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(context.l10n, actionLabel: context.l10n.actionScheduleCharging))),
    );
    if (r.success) await _reload();
  }

  Future<void> _saveWindow() async {
    final r = await ref.read(vehicleRepositoryProvider).saveChargingSchedule({
      'enabled': _enabled,
      'startChargeTime': _startCtrl.text.trim(),
      'endChargeTime': _endCtrl.text.trim(),
      'chargeWay': _chargeWay,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(context.l10n, actionLabel: context.l10n.actionScheduleCharging))),
    );
    if (r.success) await _reload();
  }

  Future<void> _startNow() async {
    final r = await ref.read(vehicleRepositoryProvider).startCharging();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(context.l10n, actionLabel: context.l10n.actionStartCharging))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    final s = _state;
    if (s == null || !s.success) {
      return Center(child: Text(l10n.scheduleInvalidResponse));
    }
    if (!s.supported) {
      return Center(
        child: Text(l10n.scheduleChargingUnsupported(s.reason ?? '—'), textAlign: TextAlign.center),
      );
    }

    return ListView(
      padding: scrollBottomPadding(context),
      children: [
        if (s.enabled != null)
          LtrMetricRow(
            label: l10n.scheduleChargingStatus,
            value: s.enabled! ? l10n.stateActive : l10n.stateInactive,
          ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(l10n.scheduleChargingEnabled),
          value: _enabled,
          onChanged: (v) {
            setState(() => _enabled = v);
            _toggle(v);
          },
        ),
        TextField(
          controller: _startCtrl,
          decoration: InputDecoration(labelText: l10n.scheduleChargingStart),
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _endCtrl,
          decoration: InputDecoration(labelText: l10n.scheduleChargingEnd),
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _chargeWay,
          decoration: InputDecoration(labelText: l10n.scheduleChargingRepeat),
          items: [
            DropdownMenuItem(value: 'e', child: Text(l10n.scheduleRepeatDaily)),
            DropdownMenuItem(value: 's', child: Text(l10n.scheduleRepeatOnce)),
          ],
          onChanged: (v) => setState(() => _chargeWay = v ?? 'e'),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _saveWindow, child: Text(l10n.scheduleChargingSaveWindow)),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: _startNow,
          child: Text(l10n.scheduleChargingStartNow),
        ),
      ],
    );
  }
}
