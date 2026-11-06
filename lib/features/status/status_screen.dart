import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/vehicle_state.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSnap = ref.watch(vehicleSnapshotProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: asyncSnap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _OfflineBody(message: e.toString()),
        data: (snap) {
          if (snap == null) {
            return const _OfflineBody(message: 'אין נתונים');
          }
          if (snap.offline || !snap.state.success) {
            return _OfflineBody(message: snap.errorMessage ?? 'לא מחובר');
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(vehicleSnapshotProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ConnectionCard(snap: snap),
                const SizedBox(height: 12),
                _MetricCard(
                  title: 'סוללה',
                  lines: [
                    if (snap.state.battery?.soc != null)
                      'SOC: ${snap.state.battery!.soc!.toStringAsFixed(1)}%',
                    if (snap.state.battery?.displayRangeKm != null)
                      'טווח: ${snap.state.battery!.displayRangeKm} km',
                  ],
                ),
                _MetricCard(
                  title: 'נעילה',
                  lines: [
                    snap.state.lockLabelHe(snap.state.isLocked),
                    if (snap.state.doors?.source != null)
                      'מקור: ${snap.state.doors!.source}',
                  ],
                ),
                if (snap.drivingLabelHe != null)
                  _MetricCard(
                    title: 'תנועה (CAN /api/gps)',
                    lines: [snap.drivingLabelHe!],
                  ),
                _MetricCard(
                  title: 'מיזוג',
                  lines: [
                    'מצב: ${snap.state.climate?.acOn == true ? 'פועל' : 'כבוי'}',
                    if (snap.state.climate?.setpointDriver != null)
                      'יעד: ${snap.state.climate!.setpointDriver!.toStringAsFixed(0)}°C',
                    if (snap.state.climate?.insideTempC != null)
                      'בתוך הרכב: ${snap.state.climate!.insideTempC!.toStringAsFixed(1)}°C',
                  ],
                ),
                if (snap.state.windows != null)
                  _MetricCard(
                    title: 'חלונות (% פתיחה)',
                    lines: [
                      'קדמי שמ: ${_pct(snap.state.windows!.lf)}',
                      'קדמי ימ: ${_pct(snap.state.windows!.rf)}',
                      'אחורי שמ: ${_pct(snap.state.windows!.lr)}',
                      'אחורי ימ: ${_pct(snap.state.windows!.rr)}',
                    ],
                  ),
                if (snap.state.tyres?.available == true) ...[
                  const SizedBox(height: 4),
                  Text('צמיגים', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _TyreRow(label: 'קדמי שמ', t: snap.state.tyres!.fl),
                  _TyreRow(label: 'קדמי ימ', t: snap.state.tyres!.fr),
                  _TyreRow(label: 'אחורי שמ', t: snap.state.tyres!.rl),
                  _TyreRow(label: 'אחורי ימ', t: snap.state.tyres!.rr),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  static String _pct(int? v) {
    if (v == null || v < 0) return '—';
    return '$v%';
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.snap});

  final VehicleSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final cloud = snap.cloud;
    return Card(
      child: ListTile(
        leading: Icon(
          snap.offline ? Icons.cloud_off : Icons.cloud_done,
          color: snap.offline ? Colors.red : Colors.green,
        ),
        title: Text(snap.offline ? 'מנותק' : 'מחובר'),
        subtitle: Text(
          cloud == null
              ? 'עדכון: ${snap.lastUpdated?.toLocal()}'
              : 'BYD Cloud: ${cloud.configured ? 'מוגדר' : 'לא מוגדר'} · '
                  '${cloud.verified ? 'מאומת' : 'לא מאומת'}',
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final line in lines) Text(line),
          ],
        ),
      ),
    );
  }
}

class _TyreRow extends StatelessWidget {
  const _TyreRow({required this.label, required this.t});

  final String label;
  final TyreCorner? t;

  @override
  Widget build(BuildContext context) {
    final corner = t;
    if (corner == null || corner.available != true) {
      return ListTile(title: Text(label), subtitle: const Text('אין אות'));
    }
    return ListTile(
      dense: true,
      title: Text(label),
      subtitle: Text('${corner.kPa} kPa · ${corner.temperatureC}°C'),
    );
  }
}

class _OfflineBody extends StatelessWidget {
  const _OfflineBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('לא מחובר לרכב', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
