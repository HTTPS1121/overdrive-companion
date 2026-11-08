import 'package:flutter/material.dart';

/// Height of [FloatingNavigationBar] outer padding + bar (must match widget).
double floatingNavScrollClearance(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 16 + 64 + 20;

/// Extra list padding so last items clear the floating nav and device insets.
EdgeInsets scrollBottomPadding(
  BuildContext context, {
  double top = 8,
  double horizontal = 20,
  double extra = 12,
}) {
  final bottom = floatingNavScrollClearance(context) + extra;
  return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
}
