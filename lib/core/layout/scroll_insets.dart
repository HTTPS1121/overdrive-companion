import 'package:flutter/material.dart';

/// Extra list padding so last items clear the bottom [NavigationBar] and device insets.
EdgeInsets scrollBottomPadding(
  BuildContext context, {
  double top = 12,
  double horizontal = 16,
  double extra = 0,
}) {
  final bottom = MediaQuery.paddingOf(context).bottom +
      kBottomNavigationBarHeight +
      16 +
      extra;
  return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
}
