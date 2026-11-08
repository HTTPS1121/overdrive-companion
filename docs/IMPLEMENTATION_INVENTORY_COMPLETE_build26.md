# Overdrive Companion — complete implementation inventory (build 26)

| Field | Value |
|-------|--------|
| Version | `2.8.4+26` (`versionCode` **26**) |
| APK on disk | **`app-release.apk` only** (no separate renamed copy in artifact dir) |
| SHA-256 | `73ebf236dc720fb35bb4f063bcb40ef42723f5aef04b1918045ecddeeaaa8200` |
| Immutable prior snapshots | `v2.8.3/` build **24**; `v2.8.4/` build **25** |
| Tests | `flutter test` → **153** (fixtures; no live vehicle/Telegram sends) |
| Goldens | `test/screenshot/goldens/v2.8.5` — **93** PNG (`17` core + `60` integration hub + `16` push-detail) |
| Manifest | `docs/RELEASE_MANIFEST_v2.8.5.json` (self-consistent filenames) |

## Build 26 QA delta (no new features)

### RoadSense map (`GeoJsonPointMap` + `flutter_map`)
- **Online:** OpenStreetMap tile layer when not in `ScreenshotScope` and tiles load.
- **Offline / fixtures:** Truthful banner + lat/lon **grid** (not faux map tiles); hazards centered with padded bounds (fixes single-point stuck in corner / clip).
- **Projection:** `CameraFit.bounds` padding; markers on map layer; coord summary chip.

### Screenshot evidence (push navigation, PhoneViewport, bundled fonts)
New goldens `push_*` (representative **light/he** + **dark/en** only):

| Golden prefix | Production route |
|---------------|------------------|
| `push_automation_settings_*` | `AutomationSettingsScreen` |
| `push_automation_edit_*` | `AutomationEditScreen` |
| `push_parking_signage_*` | `ParkingSignageScreen` |
| `push_trip_detail_*` | `TripDetailScreen` |
| `push_hu_remote_*` | `VehicleHuRemoteScreen` |
| `push_platform_telemetry_*` | `PlatformConnectorsScreen` scrolled to BYD/MQTT |
| `push_light_debug_write_*` | `LightDebugScreen` write form |
| `push_car_property_write_*` | `CarPropertyDebugScreen` write form |

Integration `int_roadsense_*` goldens regenerated for fixed map.

## Feature inventory (build 25 scope retained)

All rows in `IMPLEMENTATION_INVENTORY_COMPLETE_build25.md` remain **in app** with repository + contract tests. See that document for the per-family method table; this build does not remove any callable surface.

## Residual gaps (unchanged honesty)

Cluster touch / phone-side mirror rendering, Android Auto UI, iOS plugins, MediaCodec hardware proof on device, live-car validation, production signing, local WireGuard daemon lifecycle on HU.

*Branch `cursor/polished-companion-ui-940e`.*
