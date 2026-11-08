import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';

import '../support/fixture_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('head-unit shell, voice daemon, cluster HTTP fixtures', () async {
    final client = await FixtureOverdriveApiClient.create();
    final repo = VehicleRepository(
      settings: const AppSettings(baseUrl: 'https://fixture.test', deviceToken: 'x'),
      client: client,
    );

    final home = await repo.systemShellAction(target: 'home');
    expect(home.success, isTrue);

    final speak = await repo.speakOnHeadUnit('Hello');
    expect(speak.success, isTrue);

    final play = await repo.playHeadUnitAudio('welcome_chime.wav');
    expect(play.success, isTrue);

    final apps = await repo.fetchClusterApps();
    expect(apps['apps'], isList);

    final cast = await repo.clusterCast(action: 'start', app: 'com.byd.media');
    expect(cast.success, isTrue);

    final stop = await repo.clusterStop();
    expect(stop.success, isTrue);
  });
}
