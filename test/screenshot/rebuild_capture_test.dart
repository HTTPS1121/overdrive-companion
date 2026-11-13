import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/main.dart';

void main() {
  testWidgets('export rebuild v1 flutter screens at 390×844', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(child: OverdriveCompanionApp()),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/01_login.png'),
    );

    await tester.tap(find.text('כניסה לדמו'));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/02_home.png'),
    );

    await tester.tap(find.byKey(const ValueKey('control_lock')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/07_confirm_lock.png'),
    );
    await tester.tap(find.text('ביטול'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('btn_profile')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/08_profile.png'),
    );
    await tester.tap(find.text('×').first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('btn_menu')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/09_menu.png'),
    );
    await tester.tap(find.text('×').first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('nav_camera')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/03_camera.png'),
    );

    await tester.tap(find.byKey(const ValueKey('nav_record')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/04_recordings.png'),
    );

    await tester.tap(find.byKey(const ValueKey('nav_trip')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/05_trip.png'),
    );

    await tester.tap(find.byKey(const ValueKey('nav_more')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/06_more.png'),
    );
  });
}
