import 'dart:async';

import 'support/load_test_fonts.dart';

Future<void> testExecutable(Future<void> Function() testMain) async {
  await loadTestFonts();
  await testMain();
}
