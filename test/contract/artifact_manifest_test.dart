import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RELEASE_MANIFEST_v2.8.5 paths point at v2.8.5 artifact package', () {
    final root = Directory.current.path;
    final manifestFile = File('$root/docs/RELEASE_MANIFEST_v2.8.5.json');
    expect(manifestFile.existsSync(), isTrue);
    final m = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;

    expect(m['artifactDirectory'], 'v2.8.5');
    expect(m['screenshotArtifacts'], 'v2.8.5/screenshots');
    expect(m['goldens'], 'test/screenshot/goldens/v2.8.5');
    expect(m['apkFile'], 'app-release.apk');
    expect(m['apkArtifactName'], 'app-release.apk');
    expect(m.containsKey('implementationInventory'), isFalse);
    final complete = m['implementationInventoryComplete'] as String;
    expect(complete, matches(RegExp(r'^IMPLEMENTATION_INVENTORY_COMPLETE_build\d+\.md$')));

    expect(File('$root/docs/$complete').existsSync(), isTrue);

    final goldenDir = Directory('$root/test/screenshot/goldens/v2.8.5');
    expect(goldenDir.existsSync(), isTrue);
    final pngCount = goldenDir
        .listSync()
        .where((e) => e.path.endsWith('.png'))
        .length;
    expect(m['screenshotCount'], pngCount);
  });
}
