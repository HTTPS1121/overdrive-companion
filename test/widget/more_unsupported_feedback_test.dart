import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/hebrew_errors.dart';
import 'package:overdrive_companion/models/companion_models.dart';
import 'package:overdrive_companion/state/companion_app_controller.dart';
import 'package:overdrive_companion/ui/feedback/od_feedback.dart';
import 'package:overdrive_companion/ui/screens/main_shell.dart';

import '../support/test_app_scope.dart';

void main() {
  testWidgets('unsupported More row shows visible feedback toast', (tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final overrides = await emptyAppOverrides();
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          scaffoldMessengerKey: odRootScaffoldMessengerKey,
          home: const MainShell(),
        ),
      ),
    );

    final ctrl = ProviderScope.containerOf(tester.element(find.byType(MainShell)))
        .read(companionAppControllerProvider);
    ctrl.loginVisible = false;
    ctrl.screen = OdScreen.more;
    ctrl.notifyListeners();
    await tester.pumpAndSettle();

    await tester.tap(find.text('טעינה'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(hebrewFeatureNotOnServer()), findsWidgets);
  });
}
