import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:overdrive_companion/design/od_fonts.dart';

/// Loads bundled Hebrew, Latin, and MaterialIcons for widget/golden tests.
Future<void> loadTestFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final hebrew = FontLoader(OdFonts.hebrew)
    ..addFont(rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansHebrew-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansHebrew-Bold.ttf'));
  final latin = FontLoader(OdFonts.latin)
    ..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final icons = FontLoader(OdFonts.materialIcons)
    ..addFont(rootBundle.load('assets/fonts/MaterialIcons-Regular.otf'));
  await Future.wait([hebrew.load(), latin.load(), icons.load()]);
}
