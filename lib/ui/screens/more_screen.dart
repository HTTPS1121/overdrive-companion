import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../demo/demo_more_groups.dart';
import '../../design/od_design.dart';
import '../../icons/od_icon.dart';
import '../sheets/demo_copy_sheets.dart';
import '../widgets/od_widgets.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ListView(
          children: [
            Text('עוד אפשרויות', style: odEyebrow()),
            const SizedBox(height: 4),
            Text('השכבה שמאחורי השקט', style: odH1()),
            const SizedBox(height: 5),
            Text('כל היכולות, מאורגנות לפי הצורך.', style: odMuted()),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EBF7),
                borderRadius: BorderRadius.circular(14),
                border: const Border(right: BorderSide(color: OdColors.blue, width: 3)),
              ),
              child: Text(
                'מפת יכולות, לא הבטחת חיבור.\nמבוסס תיעוד OverDrive ציבורי. תמיכה בכל רכב ובשליטה מהטלפון לא אומתה.',
                style: TextStyle(fontSize: 13, color: const Color(0xFF264C7C), height: 1.45),
              ),
            ),
            for (final g in kMoreGroups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
                child: Text(g.title, style: odMuted(13)),
              ),
              OdCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    for (final item in g.items)
                      _MoreRow(
                        title: item.title,
                        subtitle: item.subtitle,
                        icon: _icon(g.icon),
                        onTap: () => openMoreDetailSheet(ref, item, g.title),
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  OdIconName _icon(String name) => switch (name) {
        'battery' => OdIconName.battery,
        'shield' => OdIconName.shield,
        'trip' => OdIconName.trip,
        'wave' => OdIconName.wave,
        'link' => OdIconName.link,
        _ => OdIconName.settings,
      };
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
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
