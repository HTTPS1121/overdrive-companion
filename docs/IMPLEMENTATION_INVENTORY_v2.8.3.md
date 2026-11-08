# Implementation inventory (2.8.3)

## Diagnostics & RoadSense

| Surface | UI | Repository / client | CI evidence |
|---------|----|---------------------|-------------|
| `GET /api/debug/seat/read` | `SeatDebugScreen` | `readSeatDebug` | `extended_services_contract_test.dart`, fixture mock |
| `GET /api/logs/available` + `POST /api/logs/upload` | `LogsDiagnosticScreen` (confirm) | `fetchLogsAvailable`, `uploadLogDaemon` | contract + mock (fake upload code, no exfil) |
| Car property / ADAS / light / remote-key / autoservice debug | respective screens | `fetchCarPropertyStatus`, `readCarProperty`, `resolveAdas`, `readAdasRegisters`, `resolveLightDebug`, `fetchRemoteKeyDebug`, `fetchAutoServiceDebugStatus` | contract GET fixtures |
| `GET /api/roadsense/hazards` | `RoadSenseToolsScreen` | `fetchRoadSenseHazards` | contract |
| `POST` delete-local/cloud, test-chime, hazard confirm/reject | `RoadSenseToolsScreen` (confirms on destructive) | `postRoadSenseDeleteLocal/Cloud`, `postRoadSenseTestChime`, `postRoadSenseHazardVerdict` | contract POST fixtures |

Hub entry: `DiagnosticsHubScreen` + integrations hub card. All panels show `FixtureDisclaimerBanner` in screenshot mode only.

## Voice lifecycle (audit)

- Teardown: `CommunicatePttClient` / `GenAiVoiceClient` / `CabinAudioClient` dispose mic + WS; panels cancel subs on dispose and rebind on settings/JWT changes.
- Cabin local pause during PTT; listener bytes from client (test sink in screenshots).
- Screenshot harness: `fixtureMic` / `useTestSink` / `useTestPlayback`; mic permission bypassed when `ScreenshotScope` active.
- No JWT/device tokens in screenshot labels or mock payloads (`fixture-token` only in tests).

## MediaCodec / Annex-B

| Layer | Evidence |
|-------|----------|
| Dart | `H264AnnexB` — `camera_api_contract_test.dart` |
| JVM | `AnnexBUtilsTest` — `:app:testDebugUnitTest` **passed** |
| Instrumented | `MediaCodecAnnexBInstrumentedTest` — **attempted** via `./gradlew :app:connectedDebugAndroidTest` |

**Blocker (this environment):** `DeviceException: No connected devices!` — no emulator attached in Cloud Agent VM. Test source is ready for local `connectedDebugAndroidTest`; decode success/failure is reported in assertion messages when a device is present.

## Signing

Release APK uses **debug signing** (unchanged keystore). See `releaseSigningDebugNote` in l10n and manifest `signing` field. Production signing is an external release step, not a feature gate.

## Screenshots (v2.8.3)

- Core app: `test/screenshot/render_screenshots_test.dart` → `goldens/v2.8.3/` (18 baselines).
- Integrations + voice matrix: `integration_screenshots_test.dart` — every integration family × he/en × light/dark + voice ready/unsupported/enabled/disabled (fixture disclaimer on panels).
- Artifacts: `/cursor/stores/self/artifacts/v2.8.3/screenshots/` (no runtime fixture paths in app binary).

## Test count

**136** Flutter tests passed (`flutter test`).

Goldens + manifest + APK staged under `artifacts/v2.8.3/`.
