import 'package:flutter/material.dart';

import '../config/app_settings.dart';
import '../format/display_strings.dart';
import '../theme/app_text.dart';
import '../theme/app_theme.dart';

class DemoDataBanner extends StatelessWidget {
  const DemoDataBanner({super.key, required this.mode});

  final ConnectionMode mode;

  @override
  Widget build(BuildContext context) {
    if (mode == ConnectionMode.live) return const SizedBox.shrink();

    final colors = OverdriveColors.of(context);
    final label = demoModeBannerHe(
      switch (mode) {
        ConnectionMode.embeddedMock => ConnectionModeLabel.embedded,
        ConnectionMode.localMockServer => ConnectionModeLabel.localSim,
        ConnectionMode.live => ConnectionModeLabel.live,
      },
    );

    return Material(
      color: colors.demoBanner,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'הנתונים והפקודות כאן מדומים. לחיבור לרכב אמיתי בחר «רכב» בהגדרות.',
                style: hebrewTextStyle(Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.demoBannerBorder.withValues(alpha: 0.6)),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.science_outlined, color: colors.warn, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: hebrewTextStyle(Theme.of(context).textTheme.labelLarge).copyWith(
                        color: colors.warn,
                        fontSize: 13,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
