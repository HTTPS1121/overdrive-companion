import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/core/theme/app_theme.dart';
import 'package:overdrive_companion/data/mock/mock_overdrive_backend.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/controls/controls_screen.dart';
import 'package:overdrive_companion/features/dashboard/dashboard_screen.dart';
import 'package:overdrive_companion/providers/app_providers.dart';

/// Golden PNGs rendered by Flutter test (embedded mock, RTL).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final outDir = Directory('/opt/cursor/artifacts/screenshots');
  outDir.createSync(recursive: true);

  testWidgets('write screenshot PNGs via goldens', (tester) async {
    final repo = VehicleRepository(
      settings: AppSettings.defaults(),
      mockBackend: MockOverdriveBackend(),
    );
    final snap = await repo.fetchSnapshot();
    final offline = VehicleSnapshot(
      state: VehicleState(success: false, error: 'אין רשת'),
      lastUpdated: DateTime.now(),
      offline: true,
      errorMessage: 'אין רשת',
    );

    await _golden(
      tester,
      '01_dashboard_demo',
      const DashboardScreen(),
      snap,
    );
    await _golden(tester, '02_controls_demo', const ControlsScreen(), snap);
    await _golden(
      tester,
      '04_dashboard_offline',
      const DashboardScreen(),
      offline,
    );
    await _golden(
      tester,
      '03_settings_demo',
      const _SettingsPreview(),
      snap,
    );
    for (final name in [
      '01_dashboard_demo',
      '02_controls_demo',
      '03_settings_demo',
      '04_dashboard_offline',
    ]) {
      final golden = File('test/screenshot/goldens/$name.png');
      final dest = File('${outDir.path}/$name.png');
      if (golden.existsSync()) {
        dest.writeAsBytesSync(golden.readAsBytesSync());
      }
    }
  });
}

Future<void> _golden(
  WidgetTester tester,
  String name,
  Widget child,
  VehicleSnapshot snap,
) async {
  final surface = find.byType(MaterialApp);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith(_DemoSettings.new),
        vehicleSnapshotProvider.overrideWith(() => _FixedSnapshot(snap)),
      ],
      child: MaterialApp(
        theme: buildOverdriveTheme(),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(390, 780)),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await expectLater(
    surface,
    matchesGoldenFile('goldens/$name.png'),
  );
}

class _DemoSettings extends AppSettingsNotifier {
  @override
  AppSettings build() => AppSettings.defaults();
}

class _FixedSnapshot extends VehicleSnapshotNotifier {
  _FixedSnapshot(this._snap);
  final VehicleSnapshot _snap;

  @override
  Future<VehicleSnapshot?> build() async => _snap;
}

class _SettingsPreview extends StatelessWidget {
  const _SettingsPreview();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('חיבור לשרת Overdrive ברכב', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'כתובת בסיס (HTTPS)',
            hintText: 'https://tunnel.example.com',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(labelText: 'Device token'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: null, child: Text('בדיקת חיבור')),
      ],
    ),
    );
  }
}
