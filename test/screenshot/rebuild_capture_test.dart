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

    await tester.tap(find.text('מצלמות'));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/03_camera.png'),
    );

    await tester.tap(find.text('הקלטות'));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/04_recordings.png'),
    );

    await tester.tap(find.text('נסיעות'));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/05_trip.png'),
    );

    await tester.tap(find.text('עוד'));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rebuild-v1/06_more.png'),
    );
  });
}
