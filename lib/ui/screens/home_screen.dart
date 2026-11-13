import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../icons/od_icon.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/demo_app_controller.dart';
import '../sheets/action_sheets.dart';
import '../widgets/od_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(demoAppControllerProvider);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Center(
          child: Column(
            children: [
              _CarChip(name: ctrl.carName, trim: ctrl.carTrim),
              const OdCarSideView(),
              const SizedBox(height: 10),
              Text(ctrl.parkLine(), style: odMuted(14)),
            ],
          ),
        ),
        _RangeCard(range: ctrl.rangeKm, battery: ctrl.batteryPercent),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.72,
          children: [
            for (final a in kControlActions)
              _ControlTile(
                tapKey: a.$1 == 'lock' ? const ValueKey('control_lock') : null,
                icon: _iconFor(a.$1),
                label: a.$2,
                onTap: () => showConfirmAction(context, ref, a.$1, a.$2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        OdCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('מצב הרכב', style: odH2()),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: OdColors.pillDemoBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'מדומה',
                      style: odBody(11, FontWeight.w600, OdColors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _VehicleGrid(locked: ctrl.locked),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 12),
          child: Row(
            children: [
              Text('היום בתנועה', style: odH2()),
              const Spacer(),
              Text('נתוני דוגמה', style: odMuted(12)),
            ],
          ),
        ),
        OdCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              _ListRow(
                title: 'הנסיעה האחרונה',
                subtitle: '18.6 ק״מ · 32 דקות · 2.8 קוט״ש',
                icon: OdIconName.trip,
              ),
              _ListRow(
                title: '2 אירועי חניה',
                subtitle: 'שני אירועים לבדיקה, ללא דחיפות מדומה',
                icon: OdIconName.shield,
              ),
            ],
          ),
        ),
      ],
    );
  }

  OdIconName _iconFor(String id) => switch (id) {
        'lock' => OdIconName.lock,
        'unlock' => OdIconName.unlock,
        'power' => OdIconName.power,
        'off' => OdIconName.off,
        'flash' => OdIconName.flash,
        'pin' => OdIconName.pin,
        'trunk' => OdIconName.trunk,
        'down' => OdIconName.down,
        _ => OdIconName.settings,
      };
}

class _CarChip extends StatelessWidget {
  const _CarChip({required this.name, required this.trim});

  final String name;
  final String trim;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: OdColors.line),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: OdColors.dotGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(name, style: odNum(13, weight: FontWeight.w700), textDirection: TextDirection.ltr),
          Text(' · $trim', style: odBody(13)),
        ],
      ),
    );
  }
}

class _RangeCard extends StatelessWidget {
  const _RangeCard({required this.range, required this.battery});

  final int range;
  final int battery;

  @override
  Widget build(BuildContext context) {
    return OdCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('טווח משוער', style: odMuted(12)),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$range', style: odNum(48, weight: FontWeight.w400).copyWith(letterSpacing: -2, height: 0.9)),
                        const SizedBox(width: 6),
                        Text('ק״מ', style: odMuted(16)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 14),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: OdColors.line)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('סוללה', style: odMuted(12)),
                    const SizedBox(height: 6),
                    Text('$battery%', style: odNum(28, weight: FontWeight.w600, color: OdColors.blue)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: battery / 100,
              minHeight: 6,
              backgroundColor: OdColors.line,
              valueColor: const AlwaysStoppedAnimation(OdColors.blue),
            ),
          ),
          const SizedBox(height: 13),
          const Divider(height: 1, color: OdColors.line),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('לא בטעינה', style: odMuted(11))),
              Expanded(child: Text('מגבלת טעינה 90%', style: odMuted(11), textAlign: TextAlign.center)),
              Expanded(child: Text('עודכן לפני 2 דק׳', style: odMuted(11), textAlign: TextAlign.end)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlTile extends StatelessWidget {
  const _ControlTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tapKey,
  });

  final OdIconName icon;
  final String label;
  final VoidCallback onTap;
  final Key? tapKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: tapKey,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OdRadii.control),
        side: const BorderSide(color: OdColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(OdRadii.control),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OdIcon(icon, color: OdColors.blue, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: odBody(11, FontWeight.w400).copyWith(height: 1.05),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleGrid extends StatelessWidget {
  const _VehicleGrid({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    final items = [
      (OdIconName.lock, 'דלתות', locked ? 'נעולות' : 'פתוחות לנעילה'),
      (OdIconName.window, 'חלונות', 'סגורים'),
      (OdIconName.trip, 'הילוך', 'P · 0 קמ״ש'),
      (OdIconName.climate, 'אקלים', '22° · כבוי'),
      (OdIconName.tire, 'צמיגים', '2.4 · 2.4 · 2.5 · 2.4'),
      (OdIconName.shield, 'מעקב חניה', locked ? 'דרוך' : 'מושבת'),
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OdColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 96,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final it = items[i];
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OdColors.line, width: 0.5),
            ),
            child: _vgCell(it.$1, it.$2, it.$3),
          );
        },
      ),
    );
  }
}

Widget _vgCell(OdIconName icon, String label, String value) {
  if (label.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: OdColors.vgIconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: OdIcon(icon, size: 19, color: OdColors.blue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: odMuted(11).copyWith(height: 1.15)),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'NotoSansHebrew',
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ListRow extends StatelessWidget {
  const _ListRow({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final OdIconName icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
