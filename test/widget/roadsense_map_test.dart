import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/geojson/hazard_geojson.dart';
import 'package:overdrive_companion/core/layout/screenshot_scope.dart';
import 'package:overdrive_companion/core/widgets/geojson_point_map.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';

void main() {
  test('parseHazardGeoJsonFeatures extracts two lon/lat points', () {
    final features = [
      {
        'type': 'Feature',
        'properties': {'id': 'h1', 'kind': 'pothole'},
        'geometry': {'type': 'Point', 'coordinates': [34.78, 32.08]},
      },
      {
        'type': 'Feature',
        'properties': {'id': 'h2', 'kind': 'debris'},
        'geometry': {'type': 'Point', 'coordinates': [34.792, 32.091]},
      },
    ];
    final points = parseHazardGeoJsonFeatures(features);
    expect(points.length, 2);
    expect(points.first.position.longitude, closeTo(34.78, 0.001));
    expect(points.first.position.latitude, closeTo(32.08, 0.001));
  });

  testWidgets('GeoJsonPointMap renders two place markers in fixture scope', (tester) async {
    final features = [
      {
        'type': 'Feature',
        'properties': {'id': 'h1'},
        'geometry': {'type': 'Point', 'coordinates': [34.78, 32.08]},
      },
      {
        'type': 'Feature',
        'properties': {'id': 'h2'},
        'geometry': {'type': 'Point', 'coordinates': [34.792, 32.091]},
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScreenshotScope(
          active: true,
          child: Scaffold(
            body: GeoJsonPointMap(features: features),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 1200));

    expect(find.byIcon(Icons.place), findsNWidgets(2));
    final centers = tester.getCenter(find.byIcon(Icons.place).first);
    expect(centers.dx, greaterThan(20));
    expect(centers.dy, greaterThan(20));
  });
}
