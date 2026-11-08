import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/models/remote_services_models.dart';
import 'package:overdrive_companion/data/repositories/overdrive_endpoints.dart';

import '../support/fixture_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('surveillance heatmap and filter log match handler JSON', () async {
    final client = await FixtureOverdriveApiClient.create();
    final heat = SurveillanceHeatmapState.fromJson(
      await client.getJson(OverdriveEndpoints.surveillanceHeatmap),
    );
    expect(heat.quadrants, isNotEmpty);
    expect(heat.quadrants.first.name, 'front');

    final log = SurveillanceFilterLogState.fromJson(
      await client.getJson(OverdriveEndpoints.surveillanceFilterLog),
    );
    expect(log.lines.length, 2);
  });

  test('communicate, genai, wireguard fixture routes', () async {
    final client = await FixtureOverdriveApiClient.create();
    final comm = CommunicateStatusState.fromJson(
      await client.getJson(OverdriveEndpoints.communicateStatus),
    );
    expect(comm.messagesReady, isTrue);

    final gen = GenAiStatusState.fromJson(await client.getJson(OverdriveEndpoints.genaiStatus));
    expect(gen.enabled, isTrue);

    final chat = await client.postJson(OverdriveEndpoints.genaiChat, body: {'messages': []});
    expect(chat['reply'], isNotNull);

    final wg = WireGuardStatusState.fromJson(await client.getJson(OverdriveEndpoints.wireguardStatus));
    expect(wg.configured, isTrue);

    final expose = await client.postJson(OverdriveEndpoints.wireguardExpose, body: {'enabled': true});
    expect(expose['expose_dashboard'], isTrue);

    final deterrent = await client.getBytes(OverdriveEndpoints.surveillanceScreenDeterrentImage);
    expect(deterrent.first, 0xFF);
  });
}
