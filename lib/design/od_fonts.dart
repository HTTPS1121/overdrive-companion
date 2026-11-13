/// Bundled typography matching HTML system stack (Hebrew + Latin/digits).
abstract final class OdFonts {
  static const hebrew = 'NotoSansHebrew';
  static const latin = 'NotoSans';
  static const materialIcons = 'MaterialIcons';

  static const fallback = <String>[latin, 'sans-serif'];

  static const iconFallback = <String>[materialIcons, latin];
}
