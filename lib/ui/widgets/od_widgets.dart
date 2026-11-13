import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../design/od_fonts.dart';
import '../../demo/demo_models.dart';
import '../../icons/od_icon.dart';
import '../../state/demo_app_controller.dart';
import '../sheets/demo_copy_sheets.dart';

class OdIconButton extends StatelessWidget {
  const OdIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.semanticKey,
  });

  /// Used by integration/device screenshot tests (not shown in UI).
  final Key? semanticKey;

  final Widget icon;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        key: semanticKey,
        color: OdColors.iconBtnBg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: OdColors.iconBtnBorder),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
        ),
      ),
    );
  }
}

class OdDemoBanner extends StatelessWidget {
  const OdDemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF56729B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'דמו עיצובי · כל הנתונים והפעולות מדומים',
              textAlign: TextAlign.center,
              style: odMuted(11).copyWith(color: const Color(0xFF53647C)),
            ),
          ),
        ],
      ),
    );
  }
}

class OdTopBar extends ConsumerWidget {
  const OdTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(demoAppControllerProvider);
    final subtitle = switch (ctrl.screen) {
      OdScreen.home => 'שליטה ובית',
      OdScreen.camera => 'מצלמות הרכב',
      OdScreen.record => 'אירועים והקלטות',
      OdScreen.trip => 'נסיעות ואנרגיה',
      OdScreen.more => 'יכולות ומידע',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OdIconButton(
            semanticKey: const ValueKey('btn_profile'),
            label: 'פרופיל',
            icon: const OdIcon(OdIconName.user, color: OdColors.ink),
            onPressed: () => openProfileSheet(ref),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'OVERDRIVE',
                  style: odBrand(),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: odMuted(10).copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          OdIconButton(
            semanticKey: const ValueKey('btn_menu'),
            label: 'תפריט מסך',
            icon: const OdIcon(OdIconName.menu, color: OdColors.ink),
            onPressed: () => openContextMenuSheet(ref, ctrl.screen),
          ),
        ],
      ),
    );
  }
}

class OdBottomNav extends ConsumerWidget {
  const OdBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(demoAppControllerProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;
    const tabs = [
      (OdIconName.home, OdScreen.home, 'בית'),
      (OdIconName.camera, OdScreen.camera, 'מצלמות'),
      (OdIconName.record, OdScreen.record, 'הקלטות'),
      (OdIconName.trip, OdScreen.trip, 'נסיעות'),
      (OdIconName.more, OdScreen.more, 'עוד'),
    ];

    return Positioned(
      left: 12,
      right: 12,
      bottom: 14 + bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xEBEEF1F6),
              border: Border.all(color: const Color(0xFFD6DFEC)),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'דמו · נתונים מדומים',
              style: odMuted(10).copyWith(color: const Color(0xFF4D617B)),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(OdRadii.nav),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Material(
                color: const Color(0xE0FFFFFF).withValues(alpha: 0.92),
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(OdRadii.nav),
                    border: Border.all(color: Colors.white),
                    boxShadow: const [OdShadows.nav],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      for (final t in tabs)
                        Expanded(
                          child: _NavItem(
                            key: ValueKey('nav_${t.$2.name}'),
                            active: ctrl.screen == t.$2,
                            icon: t.$1,
                            label: t.$3,
                            onTap: () => ref
                                .read(demoAppControllerProvider)
                                .setScreen(t.$2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final OdIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? OdColors.navActiveBg : Colors.transparent,
      borderRadius: BorderRadius.circular(OdRadii.navItem),
      child: InkWell(
        borderRadius: BorderRadius.circular(OdRadii.navItem),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              OdIcon(
                icon,
                size: 19,
                color: active ? OdColors.navActiveFg : OdColors.navInactive,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: OdFonts.hebrew,
                  fontFamilyFallback: OdFonts.fallback,
                  fontSize: 10,
                  height: 1.05,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? OdColors.navActiveFg : OdColors.navInactive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OdSheetOverlay extends ConsumerWidget {
  const OdSheetOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(demoAppControllerProvider);
    if (!ctrl.sheetOpen) return const SizedBox.shrink();
    final req = ctrl.sheet!;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => ctrl.closeSheet(),
        child: ColoredBox(
          color: OdColors.sheetShade,
          child: GestureDetector(
            onTap: () {},
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Material(
                  color: OdColors.bg,
                  borderRadius: BorderRadius.circular(OdRadii.sheet),
                  elevation: 24,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
                      maxWidth: 436,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBDC9DA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(child: Text(req.title, style: odH2())),
                              OdIconButton(
                                label: 'סגירה',
                                icon: const Text('×', style: TextStyle(fontSize: 24)),
                                onPressed: () => ctrl.closeSheet(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Flexible(child: SingleChildScrollView(child: req.body(context))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OdPrimaryButton extends StatelessWidget {
  const OdPrimaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: OdColors.primaryBtn,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class OdSecondaryButton extends StatelessWidget {
  const OdSecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: OdColors.secondaryBtnBg,
          foregroundColor: OdColors.secondaryBtnFg,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class OdCard extends StatelessWidget {
  const OdCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(OdRadii.card),
        border: Border.all(color: OdColors.cardBorder),
        boxShadow: const [OdShadows.card],
      ),
      child: child,
    );
  }
}
