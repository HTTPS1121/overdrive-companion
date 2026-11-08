# Overdrive Companion — complete implementation inventory (build 25)

| Field | Value |
|-------|--------|
| Version | `2.8.4+25` (`versionCode` **25**) |
| APK | `app-release.apk` |
| SHA-256 | `fc7e7363870084971f3c30d009887abc327ae414031ed4127c2091af41ca9b80` |
| Prior immutable delivery | **2.8.3+24** (`ac478058…`) in `artifacts/v2.8.3/` |
| Tests | `flutter test` → **137** passed (fixture HTTP/WS; no live car) |
| Goldens | `test/screenshot/goldens/v2.8.4` (77 PNG) |

## Implemented since build 24 (callable UI + repo)

| Upstream family | Native route | Repository | Test |
|-----------------|--------------|------------|------|
| Automations schema/state/settings | `AutomationSettingsScreen` | `fetchAutomationSchema/State/Settings`, `saveAutomationSettings` | `extended_services_contract_test.dart` |
| Automation edit (PUT) | `AutomationEditScreen` | `updateAutomation` | same |
| Parking signage | `ParkingSignageScreen` | `fetchParkingSignage`, `saveParkingSignage` | same |
| Trips detail/config/bootstrap | `TripDetailScreen`, `TripsFamilyScreen` config card | `fetchTripDetail`, `fetch/saveTripConfig`, `bootstrapTrips` | same |
| Telegram PIN | `TelegramFamilyScreen` | `submitTelegramPin` | same |
| GenAI routines accept/reject | `GenAiToolsFamilyScreen` | `decideGenAiRoutine` | same |
| GenAI incident create | form | `createGenAiIncident` | same |
| GenAI action execute | validated type/target/value form (no demo action) | `executeGenAiAction` | same |
| Launcher / BYD cloud / MQTT telemetry | `PlatformConnectorsScreen` dashboards | `fetchLauncherSummary/Appearance`, `fetchBydCloudStatus`, `fetchMqttTelemetry` | same |
| AVAS state | `AudioLibraryFamilyScreen` | `fetchAudioAvasState` | same |
| RoadSense GeoJSON map | `RoadSenseToolsScreen` → `GeoJsonPointMap` | `fetchRoadSenseHazards` | same |
| Debug writes (seat/light/car property) | seat/light/car-property screens | `writeSeatDebug`, `writeLightDebug`, `writeCarProperty` | same |
| HU shell home/back/recents/move_display | `VehicleHuRemoteScreen` | `VehicleRepository.systemShellAction` | `vehicle_hu_contract_test.dart` |
| HU voice daemon speak/message/play/stop | `VehicleHuRemoteScreen` | `speakOnHeadUnit`, `messageOnHeadUnit`, `playHeadUnitAudio`, `stopHeadUnitAudio` | same |
| Cluster cast API start/stop + apps list | `VehicleHuRemoteScreen` | `clusterCast`, `clusterStop`, `fetchClusterApps` | same |

Entry from Controls → Commands → **Head-unit remote** (`VehicleHuRemoteScreen`).

## Residual gaps (honest)

| Item | Status |
|------|--------|
| Cluster **touch** / mirror **rendering** on phone | Not implemented — hardware projection exception; only HTTP cast start/stop |
| Android Auto / AAOS projection UI | Not implemented |
| iOS PCM/H.264/voice plugins | Out of scope (Android APK) |
| MediaCodec live decode certification | JVM/instrumented partial; no CI device proof |
| Live vehicle / Telegram outbound / real HU audio | Not validated in automation |
| WireGuard `wg` daemon start/stop on HU | Config/expose only on companion |
| `POST /api/vehicle/genai` dev HU panels | Not companion flows |
| Production release signing | Debug keystore in artifact |

## Completeness conclusion

Build **25** closes the prior **repoOnly / carOnly mislabels** for tunnel-backed HTTP families: every row in the “Implemented since build 24” table has a **validated form or confirmed action** wired to the repository. Remaining gaps are **hardware rendering**, **platform (iOS)**, **daemon-local WireGuard lifecycle**, and **field hardware proof** — not missing HTTP client coverage for the listed remote APIs.

*Branch `cursor/polished-companion-ui-940e`; upstream ref unchanged `4807e943…`.*
