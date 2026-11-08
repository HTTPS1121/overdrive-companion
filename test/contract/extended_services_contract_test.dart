import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/repositories/extended_services_repository.dart';

import '../support/fixture_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('extended services fixture automations parking trips audio telegram', () async {
    final client = await FixtureOverdriveApiClient.create();
    final repo = ExtendedServicesRepository(
      settings: const AppSettings(baseUrl: 'https://fixture.test', deviceToken: 'x'),
      client: client,
    );

    final automations = await repo.listAutomations();
    expect(automations.automations, isNotEmpty);

    final parking = await repo.fetchParkingStatus();
    expect(parking.success, isTrue);

    final trips = await repo.listTrips();
    expect(trips, isNotEmpty);

    final audio = await repo.listAudioLibrary();
    expect(audio, isNotEmpty);

    final telegram = await repo.fetchTelegramStatus();
    expect(telegram.configured, isTrue);

    final routines = await repo.fetchGenAiRoutines();
    expect(routines.success, isTrue);

    final abrp = await repo.fetchAbrpStatus();
    expect(abrp['success'], isTrue);

    final mqtt = await repo.fetchMqttStatus();
    expect(mqtt['success'], isTrue);

    final seat = await repo.readSeatDebug();
    expect(seat['success'], isTrue);

    final logs = await repo.fetchLogsAvailable();
    expect(logs['available'], isTrue);

    final upload = await repo.uploadLogDaemon('overdrive');
    expect(upload['code'], isNotEmpty);

    final hazards = await repo.fetchRoadSenseHazards();
    expect(hazards['features'], isList);

    final chime = await repo.postRoadSenseTestChime({
      'severity': 'moderate',
      'channel': 'navigation',
      'volumePercent': 50,
    });
    expect(chime['success'], isTrue);

    final verdict = await repo.postRoadSenseHazardVerdict('h1', true);
    expect(verdict['success'], isTrue);
  });
}
