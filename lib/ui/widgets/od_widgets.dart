import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../design/od_fonts.dart';
import '../../models/companion_models.dart';
import '../../icons/od_icon.dart';
import '../../state/companion_app_controller.dart';
import '../sheets/context_sheets.dart';

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

/// Space reserved above the bottom nav pill (matches HTML `calc(112px + safe-area)`).
class OdChrome {
  OdChrome._();

  static const double _navOuterBottom = 14;
  static const double _navBarHeight = 62;
  static const double _contentMargin = 28;

  static double bottomInset(BuildContext context) {
    final safe = MediaQuery.paddingOf(context).bottom;
    return _navOuterBottom + safe + _navBarHeight + _contentMargin;
  }
}

/// Tab content that scrolls together with the top bar (HTML `#app` scroll model).
class OdTabScroll extends ConsumerWidget {
  const OdTabScroll({
    super.key,
    required this.children,
    this.controller,
    this.padding,
  });

  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      controller: controller,
      padding: EdgeInsets.only(bottom: OdChrome.bottomInset(context)).add(padding ?? EdgeInsets.zero),
      children: [
        const OdTopBar(),
        ...children,
      ],
    );
  }
}

class OdTopBar extends ConsumerWidget {
  const OdTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
      child: Row(
        children: [
          OdIconButton(
            semanticKey: const ValueKey('btn_profile'),
            label: 'פרופיל',
            icon: const OdIcon(OdIconName.user, color: OdColors.ink),
            onPressed: () => openProfileSheet(ref),
          ),
          Expanded(
            child: Center(
              child: Text(
                'OVERDRIVE',
                style: odBrand(),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
          OdIconButton(
            semanticKey: const ValueKey('btn_menu'),
            label: 'תפריט מסך',
            icon: const OdIcon(OdIconName.menu, color: OdColors.ink),
            onPressed: () => openContextMenuSheet(ref, ref.read(companionAppControllerProvider).screen),
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
    final ctrl = ref.watch(companionAppControllerProvider);
    final binding = WidgetsBinding.instance;
    final bottom = MediaQuery.paddingOf(context).bottom;
    const tabs = [
      (OdIconName.home, OdScreen.home, 'בית'),
      (OdIconName.camera, OdScreen.camera, 'מצלמות'),
      (OdIconName.record, OdScreen.record, 'הקלטות'),
      (OdIconName.trip, OdScreen.trip, 'נסיעות'),
      (OdIconName.more, OdScreen.more, 'עוד'),
    ];

    final navBody = Container(
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(OdRadii.nav),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [OdShadows.nav],
      ),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          for (final t in tabs)
            Expanded(
              child: _NavItem(
                key: ValueKey('nav_${t.$2.name}'),
                active: ctrl.screen == t.$2,
                icon: t.$1,
                label: t.$3,
                onTap: () => ref.read(companionAppControllerProvider).setScreen(t.$2),
              ),
            ),
        ],
      ),
    );
    final isTestBinding = binding.runtimeType.toString().contains('Test');
    final useBlur = !isTestBinding;
    return Positioned(
      left: 12,
      right: 12,
      bottom: 14 + bottom,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OdRadii.nav),
        child: useBlur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: navBody,
              )
            : navBody,
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
    final ctrl = ref.watch(companionAppControllerProvider);
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
  final VoidCallback? onPressed;

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
  final VoidCallback? onPressed;

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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(OdRadii.card),
        boxShadow: const [OdShadows.card],
      ),
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdRadii.card),
          side: const BorderSide(color: OdColors.cardBorder),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
