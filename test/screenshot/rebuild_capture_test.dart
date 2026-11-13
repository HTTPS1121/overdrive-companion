import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/main.dart';

import '../support/golden_session.dart';
import '../support/test_app_scope.dart';

Future<void> _pumpUi(WidgetTester tester, {int ms = 500}) async {
  await tester.pump(Duration(milliseconds: ms));
}

Future<void> _scrollTab(WidgetTester tester, double delta) async {
  final scrollable = find.byType(Scrollable).first;
  await tester.drag(scrollable, Offset(0, delta));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  // Full-shell golden raster stalls on headless VM; baselines in test/screenshot/real-mode/.
  testWidgets('export real-mode flutter screens at 390×844', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.devicePixelRatio = 1.0;
    });

    final overrides = await GoldenSession.overrides();

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const OverdriveCompanionApp(),
      ),
    );
    await _pumpUi(tester);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('real-mode/02_home.png'),
    );
    await _scrollTab(tester, -520);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('real-mode/02_home_scrolled.png'),
    );
    await _scrollTab(tester, 520);

    await tester.tap(find.byKey(const ValueKey('control_lock')));
    await _pumpUi(tester);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('real-mode/07_confirm_lock.png'),
    );
    await tester.tap(find.text('ביטול'));
    await _pumpUi(tester, ms: 300);

    await tester.tap(find.byKey(const ValueKey('btn_profile')));
    await _pumpUi(tester);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('real-mode/08_profile.png'),
    );
    await tester.tap(find.text('×').first);
    await _pumpUi(tester, ms: 300);

    await tester.tap(find.byKey(const ValueKey('nav_camera')));
    await _pumpUi(tester);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('real-mode/03_camera_empty.png'),
    );
    await tester.tap(find.byKey(const ValueKey('nav_record')));
    await _pumpUi(tester);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('real-mode/04_recordings_empty.png'),
    );

    await tester.tap(find.byKey(const ValueKey('nav_trip')));
    await _pumpUi(tester);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('real-mode/05_trip_empty.png'),
    );

    await tester.tap(find.byKey(const ValueKey('nav_more')));
    await _pumpUi(tester);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('real-mode/06_more.png'),
    );
  }, skip: true);

  testWidgets('login screen golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.devicePixelRatio = 1.0;
    });
    final overrides = await emptyAppOverrides();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const OverdriveCompanionApp()),
    );
    await _pumpUi(tester);
    await expectLater(
      find.byKey(const ValueKey('screenshot_root')),
      matchesGoldenFile('real-mode/01_login.png'),
    );
  });
}
