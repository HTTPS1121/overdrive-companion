import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/display_strings.dart';
import '../../core/format/freshness.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/atto3_silhouette.dart';
import '../../core/widgets/connection_status_bar.dart';
import '../../core/widgets/demo_banner.dart';
import '../../data/models/vehicle_state.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';
import 'dashboard_quick_actions.dart';

/// Space above bottom [NavigationBar] so list content does not sit underneath it.
const kDashboardBottomInset = 96.0;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final asyncSnap = ref.watch(vehicleSnapshotProvider);
    final colors = OverdriveColors.of(context);

    return Column(
      children: [
        DemoDataBanner(mode: settings.connectionMode),
        Expanded(
          child: asyncSnap.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorState(message: _friendlyError(e)),
            data: (snap) {
              if (snap == null) {
                return const _ErrorState(message: 'אין נתונים');
              }
              if (snap.offline || !snap.state.success) {
                return _OfflineDashboard(message: snap.errorMessage ?? 'לא מחובר');
              }

              final freshness = DataFreshness(
                serverEpochSec: snap.state.timestamp,
                fetchedAt: snap.lastUpdated ?? DateTime.now(),
              );

              return RefreshIndicator(
                onRefresh: () => ref.read(vehicleSnapshotProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, kDashboardBottomInset),
                  children: [
                    ConnectionStatusBar(
                      snapshot: snap,
                      freshness: freshness,
                      refreshing: asyncSnap.isLoading,
                      onRefresh: () =>
                          ref.read(vehicleSnapshotProvider.notifier).refresh(),
                    ),
                    const SizedBox(height: 12),
                    _VehicleHero(snap: snap),
                    const SizedBox(height: 14),
                    DashboardQuickActions(snap: snap),
                    const SizedBox(height: 16),
                    _CompactClimate(climate: snap.state.climate),
                    const SizedBox(height: 10),
                    _CompactWindowsDoors(
                      windows: snap.state.windows,
                      doors: snap.state.doors,
                    ),
                    if (snap.state.tyres?.available == true) ...[
                      const SizedBox(height: 10),
                      _CompactTyres(tyres: snap.state.tyres!),
                    ],
                    if (freshness.isStale) ...[
                      const SizedBox(height: 14),
                      Text(
                        'שים לב: הנתונים לא עודכנו לאחרונה. רענן לפני שליחת פקודות.',
                        style: hebrewTextStyle(
                          Theme.of(context).textTheme.bodySmall,
                        ).copyWith(color: colors.warn),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

String _friendlyError(Object e) {
  final s = e.toString();
  if (s.contains('SocketException') || s.contains('Failed host lookup')) {
    return 'בעיית רשת או כתובת שרת';
  }
  return 'שגיאת טעינה';
}

class _VehicleHero extends StatelessWidget {
  const _VehicleHero({required this.snap});

  final VehicleSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final battery = snap.state.battery;
    final soc = battery?.soc;
    final range = battery?.displayRangeKm;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        child: Column(
          children: [
            Atto3Silhouette(
              socProgress: (soc ?? 72) / 100,
              socLabel: formatSocPercent(soc),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'טווח',
                    value: formatRangeKm(range),
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'מצב',
                    valueHe: snap.drivingLabelHe ?? 'לא ידוע',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, this.value, this.valueHe});

  final String label;
  final String? value;
  final String? valueHe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: hebrewTextStyle(Theme.of(context).textTheme.labelMedium),
        ),
        const SizedBox(height: 4),
        if (value != null)
          Text(
            value!,
            style: numericTextStyle(
              Theme.of(context).textTheme.titleLarge,
              weight: FontWeight.w700,
            ),
            textDirection: TextDirection.ltr,
          )
        else
          Text(
            valueHe!,
            style: hebrewTextStyle(
              Theme.of(context).textTheme.titleMedium,
              weight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _CompactClimate extends StatelessWidget {
  const _CompactClimate({required this.climate});

  final ClimateInfo? climate;

  @override
  Widget build(BuildContext context) {
    final c = climate;
    final on = c?.acOn == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(on ? Icons.ac_unit : Icons.ac_unit_outlined, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    on ? 'מיזוג פעיל' : 'מיזוג כבוי',
                    style: hebrewTextStyle(Theme.of(context).textTheme.titleSmall),
                  ),
                  _ClimateLine(climate: c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClimateLine extends StatelessWidget {
  const _ClimateLine({required this.climate});

  final ClimateInfo? climate;

  @override
  Widget build(BuildContext context) {
    final c = climate;
    if (c == null) {
      return Text(
        'אין פרטים',
        style: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
      );
    }
    final spans = <InlineSpan>[];
    void addPart(String label, String value) {
      if (spans.isNotEmpty) {
        spans.add(TextSpan(text: kTextSep, style: numericTextStyle(Theme.of(context).textTheme.bodySmall)));
      }
      spans.add(TextSpan(text: label, style: hebrewTextStyle(Theme.of(context).textTheme.bodySmall)));
      spans.add(const TextSpan(text: ' '));
      spans.add(TextSpan(text: value, style: numericTextStyle(Theme.of(context).textTheme.bodySmall)));
    }

    if (c.setpointDriver != null) {
      addPart('יעד', formatTempC(c.setpointDriver!));
    }
    if (c.insideTempC != null) {
      addPart('פנים', formatTempC(c.insideTempC!, decimals: 1));
    }
    if (c.fanLevel != null) {
      addPart('מאוורר', '${c.fanLevel}');
    }
    if (spans.isEmpty) {
      return Text(
        'אין פרטים',
        style: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
      );
    }
    return Text.rich(TextSpan(children: spans), textDirection: TextDirection.rtl);
  }
}

class _CompactWindowsDoors extends StatelessWidget {
  const _CompactWindowsDoors({required this.windows, required this.doors});

  final WindowPercents? windows;
  final DoorLocks? doors;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'חלונות ודלתות',
              style: hebrewTextStyle(Theme.of(context).textTheme.titleSmall),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'קדמי ',
                    style: hebrewTextStyle(Theme.of(context).textTheme.bodyMedium),
                  ),
                  TextSpan(
                    text: formatWindowPct(windows?.lf),
                    style: numericTextStyle(Theme.of(context).textTheme.bodyMedium),
                  ),
                  TextSpan(
                    text: kTextSep,
                    style: numericTextStyle(Theme.of(context).textTheme.bodyMedium),
                  ),
                  TextSpan(
                    text: 'אחורי ',
                    style: hebrewTextStyle(Theme.of(context).textTheme.bodyMedium),
                  ),
                  TextSpan(
                    text: formatWindowPct(windows?.lr),
                    style: numericTextStyle(Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
              textDirection: TextDirection.rtl,
            ),
            if (doors?.source != null) ...[
              const SizedBox(height: 6),
              Text(
                'מקור נעילה ${lockSourceLabelHe(doors!.source)}',
                style: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompactTyres extends StatelessWidget {
  const _CompactTyres({required this.tyres});

  final TyreBlock tyres;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'צמיגים',
                    style: hebrewTextStyle(Theme.of(context).textTheme.titleSmall),
                  ),
                  TextSpan(
                    text: ' | TPMS',
                    style: numericTextStyle(Theme.of(context).textTheme.titleSmall),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _tyreRow(context, 'שמ׳ קד׳', tyres.fl),
            _tyreRow(context, 'ימ׳ קד׳', tyres.fr),
          ],
        ),
      ),
    );
  }

  Widget _tyreRow(BuildContext context, String label, TyreCorner? t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
            ),
          ),
          Expanded(
            child: Text(
              formatTyreLine(kPa: t?.kPa, tempC: t?.temperatureC),
              style: numericTextStyle(Theme.of(context).textTheme.bodySmall),
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = OverdriveColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 72, color: colors.danger),
            const SizedBox(height: 16),
            Text(
              'לא מחובר לרכב',
              style: hebrewTextStyle(Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: hebrewTextStyle(Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineDashboard extends StatelessWidget {
  const _OfflineDashboard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = OverdriveColors.of(context);
    return ColoredBox(
      color: const Color(0xFF0B0F14),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, kDashboardBottomInset),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 88, color: colors.danger),
              const SizedBox(height: 20),
              Text(
                'אין חיבור לרכב',
                style: hebrewTextStyle(
                  Theme.of(context).textTheme.headlineSmall,
                ).copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: hebrewTextStyle(Theme.of(context).textTheme.bodyLarge),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'בדוק מנהרה או רשת בית ורענן בהגדרות',
                style: hebrewTextStyle(
                  Theme.of(context).textTheme.bodySmall,
                ).copyWith(color: colors.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
