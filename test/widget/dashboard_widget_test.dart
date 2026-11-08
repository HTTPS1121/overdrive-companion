import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/core/theme/app_theme.dart';
import 'package:overdrive_companion/data/mock/mock_overdrive_backend.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/dashboard/dashboard_screen.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import '../screenshot/test_fonts.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ensureScreenshotFonts();
  });

  testWidgets('dashboard shows demo banner and BYD hero', (tester) async {
    final mock = MockOverdriveBackend();
    final repo = VehicleRepository(
      settings: AppSettings.defaults(),
      mockBackend: mock,
    );
    final snap = await repo.fetchSnapshot();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith(_StaticSettings.new),
          vehicleSnapshotProvider.overrideWith(() => _FixedSnapshot(snap)),
        ],
        child: MaterialApp(
          theme: buildOverdriveTheme(),
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: DashboardScreen()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('הדגמה'), findsOneWidget);
    expect(find.text('BYD Atto 3'), findsOneWidget);
    expect(find.textContaining('72'), findsWidgets);
  });
}

class _StaticSettings extends AppSettingsNotifier {
  @override
  AppSettings build() => AppSettings.defaults();
}

class _FixedSnapshot extends VehicleSnapshotNotifier {
  _FixedSnapshot(this._snap);
  final VehicleSnapshot _snap;

  @override
  Future<VehicleSnapshot?> build() async => _snap;
}
