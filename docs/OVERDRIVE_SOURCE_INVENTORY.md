# Overdrive Companion — source inventory

Mapped against upstream `Overdrive-release` @ `4807e94389de38feca3a8f8582e811a6c63eb2a2` (read-only). Each row lists HTTP contract, in-app surface, repository entry point, and contract test when present.

| Method | Path | UI | Repository | Test | Coverage |
|--------|------|----|------------|------|----------|
| GET | `/auth/status` | Connection setup, Settings | `OverdriveApiClient.fetchAuthStatus` | `tunnel_login_mock_test.dart` | In app |
| POST | `/auth/token` | Settings connect | `loginWithAccessCode` / `loginWithDeviceToken` | `tunnel_login_mock_test.dart` | In app |
| GET | `/api/vehicle/state` | Status tab | `fetchSnapshot` | `vehicle_state_contract_test.dart` | In app |
| GET | `/api/gps` | Location tab | `fetchGps` | vehicle state tests | In app |
| POST | `/api/vehicle/*` controls | Controls hub | `runControl` / dedicated POSTs | `command_response_test.dart` | In app |
| GET/POST | `/api/stream/*` | Camera hub stream panel | `fetchStreamStatus`, enable/disable/view/quality | `camera_api_contract_test.dart` | In app |
| GET | `/api/recordings` | Camera hub | `fetchRecordingsList` | `camera_api_contract_test.dart` | In app |
| GET | `/api/surveillance/heatmap` | `SurveillanceDiagnosticsPanel` | `fetchSurveillanceHeatmap` | `remote_services_contract_test.dart` | In app |
| GET | `/api/surveillance/filterlog` | `SurveillanceDiagnosticsPanel` | `fetchSurveillanceFilterLog` | `remote_services_contract_test.dart` | In app |
| GET/POST | screen-deterrent | `SurveillanceDiagnosticsPanel` | `fetchScreenDeterrentImage`, `postScreenDeterrentTest` | `remote_services_contract_test.dart` | In app |
| GET/POST | `/api/communicate/*` | `RemoteServicesScreen` | communicate methods | `remote_services_contract_test.dart` | In app |
| GET/POST | `/api/genai/*` | `RemoteServicesScreen` | GenAI methods | `remote_services_contract_test.dart` | In app |
| GET/POST | `/api/wireguard`, `/expose` | `RemoteServicesScreen` | WireGuard status + expose | `remote_services_contract_test.dart` | In app (expose only) |
| WS | `/ws?token=` | Android `H264LiveController` | native `H264StreamPlugin` | Dart `H264AnnexB` in `camera_api_contract_test.dart` | Partial — Annex-B logic verified in Dart; MediaCodec decode on device only |
| POST | `/api/wireguard/config` | — | — | — | HTTP on car Daemons UI only |
| POST | `/api/vehicle/cluster-cast` | — | — | — | Car HU projection (`cluster-cast.js`) |
| GET | `/api/vehicle/cluster-apps` | — | — | — | Car HU projection |

Full machine-readable matrix: `lib/data/capabilities/companion_parity.dart` (shown in **Settings → Server capability map**).

**Annex-B / video:** Companion does not claim decoded live video in CI. Dart helpers mirror Kotlin NAL framing; native decode requires a physical Android device with a live stream.
