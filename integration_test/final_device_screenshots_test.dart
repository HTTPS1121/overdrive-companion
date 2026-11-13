import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:overdrive_companion/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> snap(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await settle(tester);
    await binding.takeScreenshot(name);
  }

  testWidgets('device QA screenshots @ 390 logical', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OverdriveCompanionApp()));
    await snap(tester, '01_login');

    await tester.tap(find.text('כניסה לדמו'));
    await snap(tester, '02_home');

    await tester.tap(find.byKey(const ValueKey('control_lock')));
    await snap(tester, '07_confirm_lock');

    await tester.tap(find.text('ביטול'));
    await settle(tester);

    await tester.tap(find.byKey(const ValueKey('btn_profile')));
    await snap(tester, '08_profile');

    await tester.tap(find.text('×').first);
    await settle(tester);

    await tester.tap(find.byKey(const ValueKey('btn_menu')));
    await snap(tester, '09_menu');

    await tester.tap(find.text('×').first);
    await settle(tester);

    await tester.tap(find.byKey(const ValueKey('nav_camera')));
    await snap(tester, '03_camera');

    await tester.tap(find.byKey(const ValueKey('nav_record')));
    await snap(tester, '04_recordings');

    await tester.tap(find.byKey(const ValueKey('nav_trip')));
    await snap(tester, '05_trip');

    await tester.tap(find.byKey(const ValueKey('nav_more')));
    await snap(tester, '06_more');
  });
}
