import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/more_groups.dart';
import '../../data/secure_settings_store.dart';
import '../../design/od_design.dart';
import '../../icons/od_icon.dart';
import '../../models/companion_models.dart';
import '../../state/companion_app_controller.dart';
import '../screens/login_screen.dart';
import '../widgets/od_widgets.dart';

void openProfileSheet(WidgetRef ref) {
  ref.read(companionAppControllerProvider).openSheet(
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
  ref.read(companionAppControllerProvider).openSheet(
        'אפשרויות · $label',
        (_) => ContextMenuSheetBody(screen: screen),
      );
}

void openMoreDetailSheet(WidgetRef ref, MoreGroupItem item, String groupTitle) {
  ref.read(companionAppControllerProvider).openSheet(
        item.title,
        (_) => MoreDetailSheetBody(item: item, groupTitle: groupTitle),
      );
}

void openConnectionEditorSheet(WidgetRef ref) {
  final ctrl = ref.read(companionAppControllerProvider);
  ctrl.openSheet(
    'עריכת חיבור',
  (context) => LoginScreen(initialDraft: ctrl.savedConnectionDraft),
  );
}

class ProfileSheetBody extends ConsumerWidget {
  const ProfileSheetBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(companionAppControllerProvider);
    final settings = ref.read(secureSettingsStoreProvider).settingsSync;
    final modeLabel = ref.read(secureSettingsStoreProvider).connectionMode == CompanionConnectionMode.tunnel
        ? 'מנהרה מרוחקת'
        : 'רשת מקומית';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OdCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Expanded(child: Text('הפרופיל שלי', style: TextStyle(fontWeight: FontWeight.w700))),
                  OdIcon(OdIconName.user, color: OdColors.blue),
                ],
              ),
              const SizedBox(height: 12),
              _def('סוג חיבור', modeLabel),
              _def('כתובת שרת', settings.baseUrl.isEmpty ? '—' : settings.baseUrl),
              _def('מזהה מכשיר', settings.deviceId.isEmpty ? '—' : settings.deviceId),
              _def('הרכב', ctrl.carName),
            ],
          ),
        ),
        OdSecondaryButton(
          label: 'עריכת פרטי חיבור',
          onPressed: () {
            ctrl.closeSheet();
            openConnectionEditorSheet(ref);
          },
        ),
        OdPrimaryButton(
          label: 'התנתקות',
          onPressed: () async {
            await ctrl.logout();
          },
        ),
      ],
    );
  }

  Widget _def(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: odMuted()),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class MoreDetailSheetBody extends StatelessWidget {
  const MoreDetailSheetBody({super.key, required this.item, required this.groupTitle});

  final MoreGroupItem item;
  final String groupTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(groupTitle, style: odMuted(12)),
        const SizedBox(height: 8),
        Text(item.subtitle, style: odBody(14)),
      ],
    );
  }
}

class ContextMenuSheetBody extends ConsumerWidget {
  const ContextMenuSheetBody({super.key, required this.screen});

  final OdScreen screen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(companionAppControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('פעולות ומידע למסך הנוכחי.', style: odMuted()),
        const SizedBox(height: 12),
        OdSecondaryButton(
          label: 'רענון נתונים מהשרת',
          onPressed: () async {
            await ctrl.refreshAll();
            if (context.mounted) ctrl.closeSheet();
          },
        ),
        OdSecondaryButton(label: 'סגור', onPressed: ctrl.closeSheet),
      ],
    );
  }
}
