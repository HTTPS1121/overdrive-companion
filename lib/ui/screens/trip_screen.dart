import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hebrew_errors.dart';
import '../../design/od_design.dart';
import '../../models/companion_models.dart';
import '../../state/companion_app_controller.dart';
import '../widgets/od_widgets.dart';

class TripScreen extends ConsumerWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(companionAppControllerProvider);
    final trips = ctrl.trips;
    return OdTabScroll(
      children: [
        Text('לראות את הדרך', style: odEyebrow()),
        const SizedBox(height: 4),
        Text('נסיעות', style: odH1()),
        const SizedBox(height: 5),
        Text('המרחק, האנרגיה וכל מה שביניהם.', style: odMuted()),
        const SizedBox(height: 22),
        if (ctrl.tripsState == DataLoadState.loading)
          OdCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text('טוען נסיעות מהשרת…', textAlign: TextAlign.center, style: odMuted(14)),
            ),
          )
        else if (ctrl.tripsState == DataLoadState.error)
          OdCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                ctrl.tripsErrorHebrew ?? 'לא ניתן לטעון נסיעות.',
                textAlign: TextAlign.center,
                style: odBody(13, FontWeight.w600, const Color(0xFF9B1C1C)),
              ),
            ),
          )
        else if (trips.isEmpty)
          OdCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
              child: Text(hebrewTripsEmpty(), textAlign: TextAlign.center, style: odMuted(14)),
            ),
          )
        else
          ...trips.map((t) => _TripCard(trip: t)),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    return OdCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('נסיעה #${trip.id}', style: odH2()),
                const SizedBox(height: 6),
                Text(trip.subtitle, style: odMuted(12)),
              ],
            ),
          ),
          Text('DNA ${trip.overallScore}', style: odNum(14, weight: FontWeight.w700, color: OdColors.blue)),
        ],
      ),
    );
  }
}
