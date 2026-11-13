import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hebrew_errors.dart';
import '../../design/od_design.dart';
import '../widgets/od_widgets.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return OdTabScroll(
          children: [
            Text('לראות את הדרך', style: odEyebrow()),
            const SizedBox(height: 4),
            Text('נסיעות', style: odH1()),
            const SizedBox(height: 5),
            Text('המרחק, האנרגיה וכל מה שביניהם.', style: odMuted()),
            const SizedBox(height: 22),
            OdCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
                child: Text(
                  hebrewTripsEmpty(),
                  textAlign: TextAlign.center,
                  style: odMuted(14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
