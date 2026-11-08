import 'package:flutter/material.dart';

import '../config/app_settings.dart';
import '../theme/app_theme.dart';

class DemoDataBanner extends StatelessWidget {
  const DemoDataBanner({super.key, required this.mode});

  final ConnectionMode mode;

  @override
  Widget build(BuildContext context) {
    if (mode == ConnectionMode.live) return const SizedBox.shrink();

    final colors = OverdriveColors.of(context);
    final label = switch (mode) {
      ConnectionMode.embeddedMock => 'מצב הדגמה מובנה — לא נתוני רכב אמיתיים',
      ConnectionMode.localMockServer => 'שרת Mock מקומי — סימולציה בלבד',
      ConnectionMode.live => '',
    };

    return Material(
      color: colors.demoBanner,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'הנתונים והפקודות כאן מדומים. לחיבור לרכב אמיתי בחר «רכב / מנהרה» בהגדרות.',
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
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
