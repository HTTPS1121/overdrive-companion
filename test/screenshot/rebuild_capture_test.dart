import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/main.dart';

Future<void> _scrollTab(WidgetTester tester, double delta) async {
  final scrollable = find.byType(Scrollable).first;
  await tester.drag(scrollable, Offset(0, delta));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('export rebuild v1 flutter screens at 390×844', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.devicePixelRatio = 1.0;
    });

    await tester.pumpWidget(
      const ProviderScope(child: OverdriveCompanionApp()),
    );
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/01_login.png'),
    );

    await tester.tap(find.text('כניסה לדמו'));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/02_home.png'),
    );
    await _scrollTab(tester, -520);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/02_home_scrolled.png'),
    );
    await _scrollTab(tester, 520);

    await tester.tap(find.byKey(const ValueKey('control_lock')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/07_confirm_lock.png'),
    );
    await tester.tap(find.text('ביטול'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('btn_profile')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/08_profile.png'),
    );
    await tester.tap(find.text('×').first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('btn_menu')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/09_menu.png'),
    );
    await tester.tap(find.text('×').first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('nav_camera')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/03_camera.png'),
    );
    await tester.tap(find.byKey(const ValueKey('nav_record')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/04_recordings.png'),
    );
    await _scrollTab(tester, -900);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/04_recordings_scrolled.png'),
    );
    await _scrollTab(tester, 900);

    await tester.tap(find.byKey(const ValueKey('nav_trip')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/05_trip.png'),
    );
    await _scrollTab(tester, -420);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/05_trip_scrolled.png'),
    );
    await _scrollTab(tester, 420);

    await tester.tap(find.byKey(const ValueKey('nav_more')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/06_more.png'),
    );
    await _scrollTab(tester, -1200);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('rebuild-v1/06_more_scrolled.png'),
    );
  });
}
