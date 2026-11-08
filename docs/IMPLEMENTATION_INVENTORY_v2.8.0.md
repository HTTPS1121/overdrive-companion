# Overdrive Companion v2.8.0 — implementation inventory (evidence-based)

Upstream reference (read-only): `yash-srivastava/Overdrive-release` @ `4807e94389de38feca3a8f8582e811a6c63eb2a2`.

## Verification methods

| Layer | Evidence |
|-------|----------|
| Dart contracts | `flutter test` (71 tests): `test/contract/*`, fixtures in `test/support/mock_overdrive_backend.dart` shapes aligned to Java handlers |
| Auth HTTP | `local_auth_http_integration_test.dart`: Shelf server + real `dart:io` `HttpClient` via `HttpOverrides` |
| Annex-B framing | Dart `H264AnnexB` + Android `AnnexBUtilsTest` (JUnit); **not** MediaCodec decode on device/emulator in CI |
| UI | Screenshot goldens `test/screenshot/goldens/v2.7` → artifacts `v2.8.0/screenshots` |

## In-app (reachable native screen → repository → test)

| Endpoint | Screen / widget | Repository | Contract test |
|----------|-----------------|------------|---------------|
| GET `/auth/status`, POST `/auth/token` | `ConnectionSetupScreen`, `SettingsScreen` | `OverdriveApiClient` | `tunnel_login_mock_test.dart`, `auth_api_client_test.dart`, `local_auth_http_integration_test.dart` |
| GET `/api/vehicle/state`, `/api/gps` | Status, GPS tabs | `fetchSnapshot` | vehicle state tests |
| Vehicle POST controls | `ControlsHubScreen` | `runControl` | `command_response_test.dart` |
| GET/POST stream, recordings | `CameraHubScreen`, `CameraStreamPanel` | stream/recording methods | `camera_api_contract_test.dart` |
| Surveillance heatmap/filterlog/screen-deterrent | `SurveillanceDiagnosticsPanel` | `fetchSurveillanceHeatmap`, etc. | `remote_services_contract_test.dart` |
| Communicate status/settings/message/test-speaker/emergency-stop | `RemoteServicesScreen` (communicate tab) | communicate methods | `remote_services_contract_test.dart` |
| GenAI status/config/chat/test/insights | `RemoteServicesScreen` (GenAI tab) | GenAI methods | `remote_services_contract_test.dart` |
| WireGuard GET/expose/config POST/DELETE | `RemoteServicesScreen` (WireGuard tab) | WireGuard methods | `remote_services_contract_test.dart` |
| Capability matrix | `CapabilityInventoryScreen` | — (static `companion_parity.dart`) | manual / in-app |

## HTTP-callable from phone, not implemented in companion UI

Examples from `HttpServer.java` route table (tunnel JWT): `/api/automations`, `/api/parking`, `/api/abrp`, `/api/mqtt`, `/api/community`, `/api/roadsense`, `/api/trips`, `/api/charging` (standalone), `/api/launcher`, `/api/bydcloud`, `/api/telegram`, `/api/audio`, `/api/genai/routines`, `/api/genai/incidents`, `/api/genai/action/execute`, `/api/vehicle/cluster-cast`, `/api/vehicle/cluster-apps`, debug ` /api/debug/*`, etc.

**Rationale:** No PWA parity screen yet; HTTP is usable from Flutter but out of release scope. Listed in Settings → inventory with `httpOnly` coverage.

## WebSocket-only (PWA parity; not duplicate in Flutter HTTP UI)

| Path | Upstream use | Companion |
|------|--------------|-----------|
| `/ws?token=` | Live H.264 Annex-B | Android `H264StreamPlugin` + `CameraStreamPanel` |
| `/ws/communicate` | PTT voice + cabin listener streaming | Notes in Remote Services UI; HTTP covers settings/messages/speaker test |
| `/ws/genai`, `/ws/genai/chat` | Voice GenAI sessions | HTTP chat + status; WS noted in UI |

## Car-head-unit-only (not remotely meaningful from phone)

| Feature | Upstream evidence |
|---------|-------------------|
| Cluster cast / cluster apps | `cluster-cast.js`, projection handlers |
| WireGuard daemon start/stop | Daemons screen on HU (API stores config; wg start is local daemon) |

## Known limitations (honest)

1. **MediaCodec decode:** Annex-B NAL classification verified (Dart + Kotlin unit test). No emulator decode harness with sample bitstream in this CI VM; live decode requires physical Android + car/tunnel stream.
2. **Mock fixtures** approximate handler JSON; integration test uses Shelf for auth/vehicle state only — not full upstream Java stack.
3. **Risky actions** use `confirmRiskyAction`; driving guard on extended power uses GPS snapshot.
4. **Release APK** signed with debug keys in `build.gradle.kts` (Flutter template); production signing is out of scope.
