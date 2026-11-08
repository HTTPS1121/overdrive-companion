import 'package:flutter/material.dart';

/// Logical phone canvas for screenshot / preview harnesses (390×844).
const Size kPhoneLogicalSize = Size(390, 844);

class PhoneViewport extends StatelessWidget {
  const PhoneViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: const MediaQueryData(
        size: kPhoneLogicalSize,
        devicePixelRatio: 3.0,
        padding: EdgeInsets.only(top: 47),
        viewPadding: EdgeInsets.only(top: 47),
      ),
      child: SizedBox(
        width: kPhoneLogicalSize.width,
        height: kPhoneLogicalSize.height,
        child: child,
      ),
    );
  }
}
