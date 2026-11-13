import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../icons/od_icon.dart';
import '../sheets/demo_copy_sheets.dart';
import '../widgets/od_widgets.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bars = <double>[22, 35, 16, 29, 11, 32, 19];
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('השבוע שלך · נתונים מדומים', style: odMuted(12))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: OdColors.pillDemoBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('7 ימים', style: TextStyle(fontSize: 12, color: OdColors.blue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: odIsolateLtr('146.2'), style: odNum(52).copyWith(letterSpacing: -2)),
                        const TextSpan(text: ' ק״מ'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 35,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final h in bars)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Container(
                                height: h,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2C68C2),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('יום א׳', style: odMuted(12)),
                      const Spacer(),
                      Text('היום', style: odMuted(12)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 12),
              child: Row(
                children: [
                  Expanded(child: Text('הנסיעות האחרונות', style: odH2())),
                  Text('3 נסיעות דוגמה', style: odMuted(12)),
                ],
              ),
            ),
            OdCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  _TripRow(
                    title: 'הבית ← מרכז העיר',
                    subtitle: 'היום, 18:10 · 18.6 ק״מ',
                    onTap: () => openTripDetailSheet(ref, 'הבית ← מרכז העיר', 'היום, 18:10'),
                  ),
                  _TripRow(
                    title: 'מרכז העיר ← הבית',
                    subtitle: 'היום, 08:40 · 19.2 ק״מ',
                    onTap: () => openTripDetailSheet(ref, 'מרכז העיר ← הבית', 'היום, 08:40'),
                  ),
                  _TripRow(
                    title: 'הבית ← הפארק',
                    subtitle: 'אתמול, 16:20 · 8.4 ק״מ',
                    onTap: () => openTripDetailSheet(ref, 'הבית ← הפארק', 'אתמול, 16:20'),
                  ),
                ],
              ),
            ),
            OdCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _ListRow(
                title: 'DNA הנהיגה',
                subtitle: 'חלקות, יעילות ועקביות · המחשה',
                icon: OdIconName.wave,
                onTap: () => openTripDetailSheet(ref, 'DNA הנהיגה', 'המחשה לשבוע'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TripRow extends StatelessWidget {
  const _TripRow({required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: OdColors.blue, width: 2),
                    ),
                  ),
                  Container(width: 1, height: 22, color: const Color(0xFF86A4CE)),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: OdColors.blue, width: 2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: odMuted(12)),
                ],
              ),
            ),
            const Text('‹', style: TextStyle(color: OdColors.blue, fontSize: 22)),
          ],
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final OdIconName icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: OdColors.vgIconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: OdIcon(icon, color: OdColors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: odMuted(12)),
                ],
              ),
            ),
            const Text('‹', style: TextStyle(color: OdColors.blue, fontSize: 22)),
          ],
        ),
      ),
    );
  }
}
