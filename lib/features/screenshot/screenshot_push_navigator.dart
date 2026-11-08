import 'package:flutter/material.dart';

/// Production-like stack: parent route stays under pushed feature (back arrow on child AppBar).
class ScreenshotPushNavigator extends StatefulWidget {
  const ScreenshotPushNavigator({super.key, required this.parent, required this.route});

  final Widget parent;
  final Widget route;

  @override
  State<ScreenshotPushNavigator> createState() => _ScreenshotPushNavigatorState();
}

class _ScreenshotPushNavigatorState extends State<ScreenshotPushNavigator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => widget.route));
    });
  }

  @override
  Widget build(BuildContext context) => widget.parent;
}
