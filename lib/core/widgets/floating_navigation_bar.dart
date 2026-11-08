import 'package:flutter/material.dart';

/// M3 floating inset navigation bar (semantic surface, rounded clip).
class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Material(
        color: scheme.surfaceContainerHigh,
        elevation: 3,
        shadowColor: scheme.shadow.withValues(alpha: 0.35),
        surfaceTintColor: scheme.surfaceTint,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          elevation: 0,
          height: 72,
          backgroundColor: Colors.transparent,
          indicatorColor: scheme.secondaryContainer,
          onDestinationSelected: onSelected,
          destinations: destinations,
        ),
      ),
    );
  }
}
