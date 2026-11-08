import 'package:flutter/widgets.dart';

/// Test/build flag: skip network map tiles, deterministic async panels.
class ScreenshotScope extends InheritedWidget {
  const ScreenshotScope({
    super.key,
    required this.active,
    required super.child,
  });

  final bool active;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ScreenshotScope>()?.active ?? false;

  @override
  bool updateShouldNotify(ScreenshotScope oldWidget) => active != oldWidget.active;
}
