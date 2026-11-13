import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../demo/demo_models.dart';
import '../../design/od_design.dart';
import '../../icons/od_icon.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/demo_app_controller.dart';
import '../widgets/od_widgets.dart';

void openProfileSheet(WidgetRef ref) {
  ref.read(demoAppControllerProvider).openSheet(
        'המרחב שלך',
        (_) => const ProfileSheetBody(),
      );
}

void openContextMenuSheet(WidgetRef ref, OdScreen screen) {
  final label = switch (screen) {
    OdScreen.home => 'בית',
    OdScreen.camera => 'מצלמות',
    OdScreen.record => 'הקלטות',
    OdScreen.trip => 'נסיעות',
    OdScreen.more => 'עוד',
  };
  ref.read(demoAppControllerProvider).openSheet(
        'אפשרויות · $label',
        (_) => ContextMenuSheetBody(screen: screen),
      );
}

class ProfileSheetBody extends ConsumerWidget {
  const ProfileSheetBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(demoAppControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OdCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('זלמן · פרופיל דוגמה', style: TextStyle(fontWeight: FontWeight.w700))),
                  const OdIcon(OdIconName.user, color: OdColors.blue),
                ],
              ),
              const SizedBox(height: 8),
              Text('אין חשבון מחובר. נתוני הדוגמה אינם נשמרים.', style: odMuted()),
              const SizedBox(height: 12),
              _def('הרכב שלי', ctrl.carName),
              _def('שפה', 'עברית · RTL'),
              _def('חיבור', 'דמו מקומי בלבד'),
            ],
          ),
        ),
        OdSecondaryButton(label: 'פרטיות הדמו', onPressed: () {}),
        OdPrimaryButton(
          label: 'חזרה למסך הכניסה',
          onPressed: () {
            ctrl.closeSheet();
            ctrl.exitToLogin();
          },
        ),
      ],
    );
  }

  Widget _def(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(k, style: odMuted()),
          const Spacer(),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class ContextMenuSheetBody extends StatelessWidget {
  const ContextMenuSheetBody({super.key, required this.screen});

  final OdScreen screen;

  @override
  Widget build(BuildContext context) {
    final screenName = switch (screen) {
      OdScreen.home => 'בית',
      OdScreen.camera => 'מצלמות',
      OdScreen.record => 'הקלטות',
      OdScreen.trip => 'נסיעות',
      OdScreen.more => 'עוד',
    };
    final rows = <Widget>[
      _menuRow('בדיקת מצבי חיבור', 'כעת / ישן / מנותק / ללא הרשאה / שגיאה', OdIconName.link),
      _menuRow('מה אפשר לעשות כאן?', 'מדריך קצר למסך הנוכחי', OdIconName.settings),
      _menuRow('מקור הנתונים', 'יכולות מתועדות מול הצעת עיצוב', OdIconName.shield),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...rows,
        const SizedBox(height: 10),
        Text('תפריט מסך $screenName. כל הבחירות מקומיות ולא מפעילות רכב.', style: odMuted(12)),
      ],
    );
  }

  Widget _menuRow(String t, String s, OdIconName icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          OdIcon(icon, color: OdColors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(s, style: odMuted(12)),
              ],
            ),
          ),
          const Text('‹', style: TextStyle(color: OdColors.blue, fontSize: 22)),
        ],
      ),
    );
  }
}

void openTripDetailSheet(WidgetRef ref, String title, String subtitle) {
  ref.read(demoAppControllerProvider).openSheet(
        'פרטי נסיעה',
        (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OdMapIllustration(),
            const SizedBox(height: 12),
            Text('$title · $subtitle', style: odMuted()),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OdCard(padding: const EdgeInsets.all(16), child: Column(children: [Text('מרחק', style: odMuted(12)), Text('18.6', style: odNum(32)), Text('ק״מ · דוגמה', style: odMuted(12))]))),
                const SizedBox(width: 12),
                Expanded(child: OdCard(padding: const EdgeInsets.all(16), child: Column(children: [Text('זמן', style: odMuted(12)), Text('32', style: odNum(32)), Text('דקות · דוגמה', style: odMuted(12))]))),
              ],
            ),
            _tripDef('אנרגיה', '2.8 קוט״ש'),
            _tripDef('סוללה בתחילה / בסוף', '82% -> 78%'),
            Text('כל הערכים סינתטיים; ייצוא נסיעות אינו מופעל בדמו.', style: odMuted(12)),
          ],
        ),
      );
}

Widget _tripDef(String k, String v) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [Text(k, style: odMuted()), const Spacer(), Text(v)]),
  );
}

void openMoreDetailSheet(WidgetRef ref, MoreGroupItem item, String groupTitle) {
  ref.read(demoAppControllerProvider).openSheet(
        item.title,
        (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: OdColors.pillDemoBg, borderRadius: BorderRadius.circular(8)),
              child: const Text('דמו · לא מחובר', style: TextStyle(fontSize: 12, color: OdColors.blue)),
            ),
            const SizedBox(height: 12),
            Text(item.subtitle, style: odMuted()),
            const SizedBox(height: 12),
            _tripDef('קבוצה', groupTitle),
            _tripDef('מצב הדגמה', 'לקריאה בלבד'),
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EBF7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'הגדרות ברכב אינן מעידות בהכרח על שליטה מרחוק. הזמינות בטלפון טעונה בדיקה.',
                style: TextStyle(fontSize: 13, color: const Color(0xFF264C7C), height: 1.45),
              ),
            ),
          ],
        ),
      );
}
