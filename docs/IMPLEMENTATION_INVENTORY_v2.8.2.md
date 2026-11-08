# Implementation inventory (2.8.2)

Evidence maps **screen → repository/client → contract/test**. No `httpOnly` labels for families below when native UI exists.

## Voice (this release)

| Surface | UI | Client | CI evidence |
|---------|----|--------|-------------|
| `POST` start/stop + binary PCM | `CommunicateVoicePanel` hold-to-talk | `CommunicatePttClient` (`/ws/communicate`, 16 kHz s16le) | `test/voice/communicate_ptt_protocol_test.dart` + `voice_ws_mock_servers.dart` |
| Cabin listen playback | `CommunicateVoicePanel` listener toggle | `CabinAudioClient` (`/ws/cabin-audio`) + `PcmPlaybackChannel` (Android AudioTrack) | same voice tests (test sink) |
| GenAI realtime voice | `GenAiVoicePanel` | `GenAiVoiceClient` (`/ws/genai?lang=`) stop/truncate JSON | `communicate_ptt_protocol_test.dart` GenAI case |
| Mic permission | panels | `MicPermission` + `record` / `FixtureMicCapture` | fixture mode in CI (no live mic) |

**Not hardware-verified:** real car speaker/mic latency, provider GenAI upstream on vehicle, iOS playback (Android plugin only).

## Integrations hub

| Family | Screen | Repository |
|--------|--------|------------|
| Automations | `AutomationsFamilyScreen` | `ExtendedServicesRepository.list/create/test/delete` |
| Parking, trips, audio, GenAI tools, Telegram | `*FamilyScreen` | `extended_services_repository.dart` |
| ABRP / MQTT / community | `PlatformConnectorsScreen` forms | `saveAbrpConfig`, `deleteAbrpToken`, MQTT CRUD, `importCommunityAutomation` |

Contract: `test/contract/extended_services_contract_test.dart`. Parity: `lib/data/capabilities/companion_parity.dart`.

## Still car-only / partial

- Head-unit projection / Android Auto
- Full RoadSense map destructive deletes (confirm dialogs planned; not all POST wired)
- MediaCodec live H.264 decode on device
- Production APK signing

Goldens: `test/screenshot/goldens/v2.8` (17+). Manifest: `docs/RELEASE_MANIFEST_v2.8.2.json` after release build.
