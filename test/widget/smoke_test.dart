import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/main.dart';

void main() {
  testWidgets('login screen shows enter demo', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OverdriveCompanionApp()));
    await tester.pumpAndSettle();
    expect(find.text('כניסה לדמו'), findsOneWidget);
  });

  testWidgets('enter demo shows home tab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ProviderScope(child: OverdriveCompanionApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('כניסה לדמו'));
    await tester.pumpAndSettle();
    expect(find.text('בית'), findsWidgets);
    expect(find.text('BYD Atto 3'), findsWidgets);
  });
}
