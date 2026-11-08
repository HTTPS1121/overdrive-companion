import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/widgets/ltr_metric.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/remote_feature_models.dart';
import '../../providers/app_providers.dart';
import 'ac_charge_current_panel.dart';

class ChargeCapPanel extends ConsumerStatefulWidget {
  const ChargeCapPanel({super.key});

  @override
  ConsumerState<ChargeCapPanel> createState() => _ChargeCapPanelState();
}

class _ChargeCapPanelState extends ConsumerState<ChargeCapPanel> {
  ChargeCapState? _state;
  bool _loading = true;
  String? _error;
  bool _saving = false;
  late int _percent;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _percent = 80;
    _enabled = false;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await ref.read(vehicleRepositoryProvider).fetchChargeCap();
      if (!mounted) return;
      setState(() {
        _state = s;
        _loading = false;
        if (s.supported) {
          _percent = (s.percent ?? 80).clamp(50, 100);
          _enabled = s.enabled ?? false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    final r = await ref.read(vehicleRepositoryProvider).postChargeCap(
          percent: _percent,
          enabled: _enabled,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(l10n, actionLabel: l10n.chargeCapTitle))),
    );
    if (r.success) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _state == null || !_state!.success
                  ? Center(child: Text(l10n.chargeCapLoadFailed))
                  : !_state!.supported
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.chargeCapUnsupported,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text(l10n.chargeCapTitle, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text(l10n.chargeCapDescription, style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 16),
                            LtrMetricRow(
                              label: l10n.chargeCapTarget,
                              value: '$_percent%',
                            ),
                            Slider(
                              min: 50,
                              max: 100,
                              divisions: 10,
                              label: '$_percent%',
                              value: _percent.toDouble(),
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(() => _percent = v.round()),
                            ),
                            SwitchListTile(
                              title: Text(l10n.chargeCapEnableTitle),
                              subtitle: Text(l10n.chargeCapEnableSubtitle),
                              value: _enabled,
                              onChanged: _saving ? null : (v) => setState(() => _enabled = v),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(l10n.chargeCapSave),
                            ),
                            const AcChargeCurrentPanel(),
                          ],
                        ),
    );
  }
}
