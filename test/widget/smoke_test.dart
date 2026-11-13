import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/main.dart';

import '../support/test_app_scope.dart';

void main() {
  testWidgets('login screen shows connect form', (tester) async {
    final overrides = await emptyAppOverrides();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const OverdriveCompanionApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('התחברות'), findsOneWidget);
    expect(find.text('בדיקת חיבור'), findsOneWidget);
    expect(find.text('סוג חיבור'), findsOneWidget);
  });

}
