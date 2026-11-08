import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/ltr_metric.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/remote_feature_models.dart';
import '../../providers/app_providers.dart';

/// מגבלת טעינה — GET/POST `/api/vehicle/charge-cap`.
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
    setState(() => _saving = true);
    final r = await ref.read(vehicleRepositoryProvider).postChargeCap(
          percent: _percent,
          enabled: _enabled,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessageHe(actionLabel: 'מגבלת טעינה'))),
    );
    if (r.success) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return RequiresConnection(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _state == null || !_state!.success
                  ? const Center(child: Text('לא ניתן לטעון מגבלת טעינה מהשרת'))
                  : !_state!.supported
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'השרת דיווח שמגבלת טעינה אינה נתמכת במכונית זו',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text(
                              'מגבלת טעינה',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'הגבלת אחוז סוללה מקסימלי בטעינה.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            LtrMetricRow(
                              label: 'יעד טעינה',
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
                              title: const Text('הפעלת מגבלה'),
                              subtitle: const Text('כאשר פעיל, הטעינה תיעצר ביעד שנבחר'),
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
                              label: const Text('שמירה לשרת'),
                            ),
                          ],
                        ),
    );
  }
}
