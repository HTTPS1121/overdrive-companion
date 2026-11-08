import 'package:flutter/material.dart';

/// Exposes main-tab selection from [AppShell] without new routes.
class StatusShellScope extends InheritedWidget {
  const StatusShellScope({
    super.key,
    required this.selectTab,
    required super.child,
  });

  final ValueChanged<int> selectTab;

  static StatusShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StatusShellScope>();

  @override
  bool updateShouldNotify(StatusShellScope oldWidget) =>
      oldWidget.selectTab != selectTab;
}
