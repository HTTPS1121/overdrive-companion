import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/demo_app_controller.dart';
import '../widgets/od_widgets.dart';

const kControlActions = [
  ('lock', 'נעילה', true),
  ('unlock', 'פתיחה', true),
  ('power', 'הדלקה', true),
  ('off', 'כיבוי', true),
  ('flash', 'הבהוב', false),
  ('pin', 'איתור', true),
  ('trunk', 'פתיחת תא', true),
  ('down', 'סגירת תא', true),
];

void showConfirmAction(BuildContext context, WidgetRef ref, String id, String label) {
  final ctrl = ref.read(demoAppControllerProvider);
  ctrl.openSheet(
    '$label — הדמיה',
    (_) => _ConfirmBody(actionId: id, label: label),
  );
}

class _ConfirmBody extends ConsumerWidget {
  const _ConfirmBody({required this.actionId, required this.label});

  final String actionId;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(demoAppControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('לבצע הדמיה של פעולת $label?', style: odMuted()),
        const SizedBox(height: 16),
        OdCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('הרכב שלי · ${ctrl.carName}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'אין פקודה שנשלחת לרכב.',
                style: odMuted(),
              ),
            ],
          ),
        ),
        OdPrimaryButton(
          label: 'אישור הדמיה בלבד',
          onPressed: () async {
            await ctrl.confirmAction(actionId);
            ctrl.openSheet('תוצאת ההדמיה', (_) => _ResultBody(actionId: actionId, label: label));
          },
        ),
        OdSecondaryButton(label: 'ביטול', onPressed: ctrl.closeSheet),
      ],
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.actionId, required this.label});

  final String actionId;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xFFD9EEE3),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text('✓', style: TextStyle(fontSize: 28, color: Color(0xFF176044))),
        ),
        const SizedBox(height: 16),
        Text('$label הודגמה', style: odH2()),
        const SizedBox(height: 8),
        Text(
          'מצב הרכב האמיתי לא השתנה.\nלא בוצעה פנייה לשרת או למערכת הרכב.',
          textAlign: TextAlign.center,
          style: odMuted(),
        ),
        if (actionId == 'pin') ...[
          const SizedBox(height: 16),
          const OdMapIllustration(),
          const SizedBox(height: 8),
          Text('נקודת מיקום מומצאת לצורך ההמחשה בלבד.', style: odMuted(12)),
        ],
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, _) => OdPrimaryButton(
            label: 'הבנתי',
            onPressed: () => ref.read(demoAppControllerProvider).closeSheet(),
          ),
        ),
      ],
    );
  }
}
