import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/companion_app_controller.dart';
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
  final ctrl = ref.read(companionAppControllerProvider);
  final needsConfirm = kControlActions.firstWhere((a) => a.$1 == id).$3;
  if (!needsConfirm) {
    _runAndShowResult(ref, id, label);
    return;
  }
  ctrl.openSheet(
    label,
    (_) => _ConfirmBody(actionId: id, label: label),
  );
}

Future<void> _runAndShowResult(WidgetRef ref, String id, String label) async {
  final ctrl = ref.read(companionAppControllerProvider);
  final result = await ctrl.confirmAction(id);
  if (result.ok) {
    ctrl.openSheet(label, (_) => _ResultBody(ok: true, label: label, message: result.message));
  } else {
    ctrl.openSheet(label, (_) => _ResultBody(ok: false, label: label, message: result.errorHebrew));
  }
}

class _ConfirmBody extends ConsumerWidget {
  const _ConfirmBody({required this.actionId, required this.label});

  final String actionId;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(companionAppControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('לבצע $label?', style: odMuted()),
        const SizedBox(height: 16),
        OdCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('הרכב שלי · ${ctrl.carName}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'הפקודה תישלח לשרת Overdrive ברכב. ודא שהרכב במצב המתאים.',
                style: odMuted(),
              ),
            ],
          ),
        ),
        OdPrimaryButton(
          label: 'אישור',
          onPressed: () async {
            final result = await ctrl.confirmAction(actionId);
            if (result.ok) {
              ctrl.openSheet(
                label,
                (_) => _ResultBody(ok: true, label: label, message: result.message),
              );
            } else {
              ctrl.openSheet(
                label,
                (_) => _ResultBody(ok: false, label: label, message: result.errorHebrew),
              );
            }
          },
        ),
        OdSecondaryButton(label: 'ביטול', onPressed: ctrl.closeSheet),
      ],
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.ok,
    required this.label,
    this.message,
  });

  final bool ok;
  final String label;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: ok ? const Color(0xFFD9EEE3) : const Color(0xFFF5D9D9),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            ok ? '✓' : '!',
            style: TextStyle(fontSize: 28, color: ok ? const Color(0xFF176044) : const Color(0xFF8A1F1F)),
          ),
        ),
        const SizedBox(height: 16),
        Text(ok ? '$label בוצע' : '$label נכשל', style: odH2()),
        const SizedBox(height: 8),
        Text(
          message ?? (ok ? 'השרת אישר את הפעולה.' : 'השרת לא ביצע את הפעולה.'),
          textAlign: TextAlign.center,
          style: odMuted(),
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, _) => OdPrimaryButton(
            label: 'הבנתי',
            onPressed: () => ref.read(companionAppControllerProvider).closeSheet(),
          ),
        ),
      ],
    );
  }
}
