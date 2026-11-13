import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/demo_app_controller.dart';
import '../widgets/od_widgets.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: OdColors.bg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 28 + top, 24, 24 + bottom),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OVERDRIVE', style: odBrand(), textDirection: TextDirection.ltr),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF56729B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'ONE ZERO inspiration · עיצוב מקורי',
                              style: odMuted(11).copyWith(color: const Color(0xFF53647C)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'כל מה שחשוב.\nבמבט אחד.',
                        style: odH1(42).copyWith(letterSpacing: -1.5, height: 1.12),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'יותר בהירות. פחות רעש.\nמרחב אחד לרכב, לאנרגיה ולדרך.',
                        style: odMuted(),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(OdRadii.card),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E4F83), Color(0xFF0C294E)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text('מוכנים לדרך', style: TextStyle(color: Colors.white)),
                                ),
                                const Text(
                                  'BYD Atto 3',
                                  style: TextStyle(color: Color(0xFFD1DEF0), fontSize: 13),
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '312',
                                    style: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w300),
                                  ),
                                  TextSpan(text: ' ק״מ טווח מדומה', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const OdCarSideView(height: 116),
                            Text('איור מקורי · לא צילום הרכב שלך', style: odMuted(13).copyWith(color: const Color(0xFFD1DEF0))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              OdPrimaryButton(
                label: 'כניסה לדמו',
                onPressed: () => ref.read(demoAppControllerProvider).enterDemo(),
              ),
              const SizedBox(height: 12),
              Text(
                'ללא חשבון או סיסמה. אין חיבור לרכב ואין ביצוע פקודות. התאמה לאייפון ולאנדרואיד היא הצעת עיצוב.',
                style: odMuted(12).copyWith(height: 1.7),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
