# Overdrive Companion — complete implementation inventory (build 27)

| Field | Value |
|-------|--------|
| Version | `2.8.4+27` (`versionCode` **27**) |
| APK | `app-release.apk` (sole binary name in artifact dir) |
| Manifest | `RELEASE_MANIFEST_v2.8.5.json` |
| Inventory (this file) | `IMPLEMENTATION_INVENTORY_COMPLETE_build27.md` |
| Tests | `flutter test` — fixture HTTP/WS only |
| Goldens | `test/screenshot/goldens/v2.8.5` (93 PNG: 17 core + 60 integration + 16 push) |
| Immutable snapshots | `v2.8.3/` b24 · `v2.8.4/` b25 · `v2.8.5/` b26 |

## Build 27 fixes (bugs only)

| Issue | Fix | Tests |
|-------|-----|-------|
| RoadSense map: count 2, **0 markers** (grid painted over `FlutterMap`) | Grid layer **behind** map; shared `parseHazardGeoJsonFeatures`; marker count chip | `roadsense_map_test.dart`, `hazard_geojson.dart` |
| MQTT telemetry `172999` year | `parseVehicleTimestampValue` — s / ms / µs / ISO | `timestamp_normalize_test.dart` |
| Inventory b26 → missing b25 table | Full feature table **in this file** (below) | — |

## Callable feature matrix (in-app)

| Upstream family | Native route | Repository | Contract test |
|-----------------|--------------|------------|---------------|
| Automations schema/state/settings | `AutomationSettingsScreen` | `fetchAutomationSchema/State/Settings`, `saveAutomationSettings` | `extended_services_contract_test.dart` |
| Automation edit (PUT) | `AutomationEditScreen` | `updateAutomation` | same |
| Parking signage | `ParkingSignageScreen` | `fetchParkingSignage`, `saveParkingSignage` | same |
| Trips detail/config/bootstrap | `TripDetailScreen`, `TripsFamilyScreen` | `fetchTripDetail`, trip config/bootstrap | same |
| Telegram PIN | `TelegramFamilyScreen` | `submitTelegramPin` | same |
| GenAI routines / incidents / action | `GenAiToolsFamilyScreen` | `decideGenAiRoutine`, `createGenAiIncident`, `executeGenAiAction` | same |
| Launcher / BYD cloud / MQTT telemetry | `PlatformConnectorsScreen` | launcher, `fetchBydCloudStatus`, `fetchMqttTelemetry` | same |
| AVAS state | `AudioLibraryFamilyScreen` | `fetchAudioAvasState` | same |
| RoadSense map + maintenance | `RoadSenseToolsScreen` | `fetchRoadSenseHazards`, POST maintenance | same + map widget test |
| Debug writes | seat / light / car-property screens | `writeSeatDebug`, `writeLightDebug`, `writeCarProperty` | same |
| HU shell + voice + cluster API | `VehicleHuRemoteScreen` | `systemShellAction`, speak/message/audio, cluster cast | `vehicle_hu_contract_test.dart` |
| Primary shell / controls / cameras / remote WS | existing tabs | `VehicleRepository`, voice clients | contract + screenshot suites |

Push-route screenshot goldens: `push_automation_settings`, `push_automation_edit`, `push_parking_signage`, `push_trip_detail`, `push_hu_remote`, `push_platform_telemetry`, `push_light_debug_write`, `push_car_property_write` (light/he + dark/en representative).

## Residual gaps (honest)

Cluster touch / phone mirror UI, Android Auto, iOS plugins, MediaCodec proof on physical device, live car / Telegram sends, HU WireGuard daemon lifecycle, production APK signing.

*Upstream ref read-only `4807e94389de38feca3a8f8582e811a6c63eb2a2`.*
