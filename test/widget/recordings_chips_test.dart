import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/real_vehicle_repository.dart';
import 'package:overdrive_companion/models/companion_models.dart';
import 'package:overdrive_companion/data/secure_settings_store.dart';
import 'package:overdrive_companion/state/companion_app_controller.dart';
import 'package:overdrive_companion/ui/feedback/od_feedback.dart';
import 'package:overdrive_companion/ui/screens/recordings_screen.dart';
import 'package:overdrive_server/overdrive_server.dart';

import '../support/test_app_scope.dart';

void main() {
  testWidgets('type chips show full labels at 390dp RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    FlutterSecureStorage.setMockInitialValues({});
    final store = await SecureSettingsStore.open();
    final client = OverdriveApiClient(baseUrl: 'http://127.0.0.1:9');
    final repo = RealVehicleRepository(client);
    debugSetRecordingStats(
      repo,
      const RecordingStatsSnapshot(
        available: true,
        totalSizeFormatted: '6.1 GB',
        usageFraction: 0.24,
        totalTodayCount: 1,
        oemDvrLabel: 'מצלמת הדרך של היצרן',
      ),
    );
    final ctrl = CompanionAppController(repo, store, client, skipBootstrap: true);
    ctrl.debugEnterSignedIn();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureSettingsStoreProvider.overrideWithValue(store),
          vehicleRepoProvider.overrideWith((ref) => repo),
          companionAppControllerProvider.overrideWith((ref) => ctrl),
        ],
        child: MaterialApp(
          scaffoldMessengerKey: odRootScaffoldMessengerKey,
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: RecordingsScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    const replayLabel = 'הילוכים חוזרים';
    expect(find.text(replayLabel), findsOneWidget);

    final box = tester.renderObject<RenderBox>(find.text(replayLabel));
    expect(box.size.width, greaterThan(88));

    expect(find.text('בעל חיים'), findsOneWidget);
    final animal = tester.renderObject<RenderBox>(find.text('בעל חיים'));
    expect(animal.size.width, greaterThan(52));

    expect(find.text('רחוק'), findsOneWidget);
    final far = tester.renderObject<RenderBox>(find.text('רחוק'));
    expect(far.size.width, greaterThan(28));
  });
}
