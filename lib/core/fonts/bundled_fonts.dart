import 'package:flutter/services.dart';

bool _loaded = false;

/// Loads Noto Hebrew + Material Icons from assets (required for headless goldens).
Future<void> ensureBundledFontsLoaded() async {
  if (_loaded) return;
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('assets/fonts/MaterialIcons-Regular.otf'));
  final hebrew = FontLoader('NotoSansHebrew')
    ..addFont(rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansHebrew-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansHebrew-Bold.ttf'));
  final latin = FontLoader('NotoSans')
    ..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  await Future.wait([icons.load(), hebrew.load(), latin.load()]);
  _loaded = true;
}
