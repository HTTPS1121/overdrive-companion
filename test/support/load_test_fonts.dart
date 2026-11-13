import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads bundled NotoSansHebrew so widget/golden tests render Hebrew (not Ahem).
Future<void> loadTestFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('NotoSansHebrew')
    ..addFont(rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansHebrew-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansHebrew-Bold.ttf'));
  await loader.load();
}
