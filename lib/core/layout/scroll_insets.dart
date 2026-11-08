import 'package:flutter/material.dart';

/// Extra list padding so last items clear the bottom [NavigationBar] and device insets.
EdgeInsets scrollBottomPadding(BuildContext context, {double top = 12, double horizontal = 16}) {
  final bottom = MediaQuery.paddingOf(context).bottom +
      kBottomNavigationBarHeight +
      16;
  return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
}
