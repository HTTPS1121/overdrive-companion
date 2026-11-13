import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:overdrive_companion/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> snap(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    await binding.takeScreenshot(name);
  }

  testWidgets('capture rebuild v1 screens at 390px', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: OverdriveCompanionApp()));
    await tester.pumpAndSettle();
    await snap(tester, '01_login');

    await tester.tap(find.text('כניסה לדמו'));
    await tester.pumpAndSettle();
    await snap(tester, '02_home');

    await tester.tap(find.text('מצלמות'));
    await tester.pumpAndSettle();
    await snap(tester, '03_camera');

    await tester.tap(find.text('הקלטות'));
    await tester.pumpAndSettle();
    await snap(tester, '04_recordings');

    await tester.tap(find.text('נסיעות'));
    await tester.pumpAndSettle();
    await snap(tester, '05_trip');

    await tester.tap(find.text('עוד'));
    await tester.pumpAndSettle();
    await snap(tester, '06_more');
  });
}
