# Overdrive Companion — complete implementation inventory (build 24)

**Delivery artifact (immutable for this documentation pass):**

| Field | Value |
|-------|--------|
| Version | `2.8.3+24` (`versionCode` **24**) |
| APK file | `app-release.apk` (also `overdrive-companion-2.8.3.apk`) |
| SHA-256 | `ac4780583e403bda4eb0277493cfe4ab2eda76322421f2c96cd870e5ae463366` |
| Size | 60,562,795 bytes |
| Signing | Debug keystore (Flutter template release) — **not** production store signing |
| Upstream reference (read-only) | `yash-srivastava/Overdrive-release` @ `4807e94389de38feca3a8f8582e811a6c63eb2a2` |
| Agent Store path | `/cursor/stores/self/artifacts/v2.8.3/` |

**Evidence types used in this document:**

- **inApp** — native screen + repository/client call intended for end users (or advanced diagnostics with warnings).
- **partial** — implemented with documented hardware/protocol/CI limits.
- **repoOnly** — HTTP client method exists; **no** dedicated user-facing UI (may be used internally or awaiting UI).
- **carOnly** — belongs on vehicle head unit / projection / daemon UI; companion intentionally omits.
- **unimplemented** — known upstream surface with no companion wiring.

**Test suite (build 24):** `flutter test` — **136** tests. **Not** live vehicle, **not** outbound Telegram/messaging in CI (fixture mocks only). Ordinary POSTs run only from explicit in-app user actions.

**Screenshot evidence:** 77 PNGs — `test/screenshot/goldens/v2.8.3` (17 core navigation + 60 integration/voice). See `RELEASE_MANIFEST_v2.8.3.json` breakdown.

**In-app parity matrix (subset):** `lib/data/capabilities/companion_parity.dart` → **Settings → Server capability map**. That list is **not exhaustive**; this document is the consolidated truth.

---

## 1. Shell navigation (primary routes)

| Tab (he/en) | Screen | Main repository |
|-------------|--------|-----------------|
| Status | `VehicleStatusScreen` | `VehicleRepository.fetchSnapshot` |
| Controls | `ControlsHubScreen` → schedules / comfort / charge / commands / extended | `VehicleRepository` + panels |
| Cameras | `CameraHubScreen` → stream / recordings / surveillance | `VehicleRepository` stream + surveillance |
| Location | `GpsScreen` | `VehicleRepository.fetchGps` |
| Settings | `SettingsScreen` → connection, **Remote services**, **Integrations hub**, **Advanced diagnostics**, capability map | `SettingsRepository`, `ExtendedServicesRepository` |

---

## 2. Auth & tunnel

| Method | Path | Native route | Repository | Contract / test |
|--------|------|--------------|------------|-----------------|
| GET | `/auth/status` | `ConnectionSetupScreen`, `SettingsScreen` | `OverdriveApiClient.fetchAuthStatus` | `tunnel_login_mock_test.dart`, `auth_contract_test.dart` |
| POST | `/auth/token` | Settings connect / save | `loginWithAccessCode`, JWT storage | `tunnel_login_mock_test.dart`, `local_auth_http_integration_test.dart` |

**Limits:** Rate-limit and HTML mis-route surfaced via l10n; no live tunnel required in CI.

---

## 3. Vehicle status & location

| Method | Path | Native route | Repository | Contract / test |
|--------|------|--------------|------------|-----------------|
| GET | `/api/vehicle/state` | Status tab, hero, freshness | `fetchSnapshot` | `vehicle_api_test.dart`, handler shape tests |
| GET | `/api/vehicle/cloud-status` | Status (cloud card) | `fetchSnapshot` / cloud fields | handler shapes |
| GET | `/api/gps` | Location tab | `fetchGps` | `vehicle_api_test.dart` |

---

## 4. Controls hub (vehicle commands)

| Method | Path | Native route | Repository | Contract / test |
|--------|------|--------------|------------|-----------------|
| POST | `/api/vehicle/lock` | Controls → Commands | `runControl` | `command_response_test.dart` |
| POST | `/api/vehicle/unlock` | Commands | `runControl` |同上 |
| POST | `/api/vehicle/trunk` | Commands | `runControl` | widget confirms |
| POST | `/api/vehicle/window` | Commands | `runControl` |同上 |
| POST | `/api/vehicle/flash` | Commands | `runControl` |同上 |
| POST | `/api/vehicle/find-car` | Commands | `findCar` |同上 |
| POST | `/api/vehicle/climate` | Commands / comfort | `runControl`, climate actions | handler shapes |
| POST | `/api/vehicle/lights` | Commands / comfort | `runControl` |同上 |
| POST | `/api/vehicle/power-on` | Extended commands | `vehiclePowerOn` | `extended_controls_test.dart` |
| POST | `/api/vehicle/power-off` | Extended commands | `vehiclePowerOff` |同上 |
| POST | `/api/vehicle/battery-heat` | Extended commands | `setBatteryHeat` |同上 |
| POST | `/api/vehicle/system` | Extended → HU/cluster **screenshot** only (`target: screenshot`, display 0/1) | `systemScreenshot` | `extended_controls_test.dart` |
| GET/POST | `/api/vehicle/climate-schedule` | Schedules tab | `fetchClimateSchedule`, `saveClimateSchedule` | `climate_schedule_mutation_test.dart` |
| GET/POST | `/api/vehicle/charging-schedule` | Schedules tab | `fetchChargingSchedule`, `saveChargingSchedule` | handler shapes |
| POST | `/api/vehicle/start-charging` | Schedules / charge | `startCharging` | mock backend |
| GET/POST | `/api/vehicle/seat` | Comfort | `postSeat` | comfort UI |
| GET/POST | `/api/vehicle/adas` | Comfort | `postAdas`, `fetchAdasState` | comfort UI |
| GET/POST | `/api/vehicle/setting` | Comfort | `postVehicleSetting` | comfort UI |
| GET/POST | `/api/vehicle/media` | Comfort | `postMedia` | comfort UI |
| GET/POST | `/api/vehicle/charge-cap` | Charge tab | `fetchChargeCap`, `postChargeCap` | mock flow |
| GET/POST | `/api/vehicle/ac-charge-current-limit` | Charge tab (`AcChargeCurrentPanel`) | `fetchAcChargeCurrentLimit`, `setAcChargeCurrentLimit` | `ac_charge_current_limit_test.dart` |

**Driving guard:** UI blocks some actions when vehicle reports in-motion (status-driven).

**carOnly / not in companion (by design):**

| Path | Reason |
|------|--------|
| `POST /api/vehicle/system` with targets other than `screenshot` | HU shell navigation (home/recents/move display) |
| `POST /api/vehicle/cluster-cast`, `cluster-stop`, `cluster-touch`, … | Cluster mirror / cast on HU |
| `GET /api/vehicle/cluster-apps` | Launcher list for projection |
| `POST /api/vehicle/play-audio`, `stop-audio`, `speak`, `message` | HU voice daemon (distinct from `/api/audio/library`) |
| `POST /api/system/ivi-reboot` | Service/factory |
| `POST /api/vehicle/genai`, `dev-view`, HU `communicate` dev panels | Vehicle dev HTML, not phone companion |

---

## 5. Cameras, stream, recordings, surveillance

| Method | Path | Native route | Repository | Contract / test |
|--------|------|--------------|------------|-----------------|
| GET | `/api/stream/status` | `CameraStreamPanel` | `fetchStreamStatus` | `camera_api_contract_test.dart` |
| POST | `/api/stream/enable`, `/disable` | Stream panel | `enableStream`, `disableStream` |同上 |
| POST | `/api/stream/view`, `/quality` | Stream panel | `setStreamViewMode`, `setStreamQuality` |同上 |
| WS | `/ws?token=` (H.264 Annex-B) | `OverdriveLivePreview` (Android) | `H264LiveController`, `H264StreamPlugin` | **partial** — `H264AnnexB` + `AnnexBUtilsTest` (JVM); `MediaCodecAnnexBInstrumentedTest` not run in CI (no device) |
| GET | `/api/recordings` | Camera hub list | `fetchRecordingsList` | `camera_api_contract_test.dart` |
| GET | `/video/id/`, `/thumb/id/` | `RecordingPlayerScreen` | `downloadRecordingBytes` | mock bytes |
| DELETE | `/api/recordings/id/` | Recordings list | `deleteRecording` | mock |
| GET/POST | `/api/surveillance/*` | `SurveillanceDiagnosticsPanel`, config toggles | status, config, enable/disable, snapshot, heatmap, filter log, deterrent | `remote_services_contract_test.dart` |

**Limits:** Live decode on **Android** only; iOS has no PCM/H264 native plugin parity. No verified end-to-end stream against a real car in CI.

---

## 6. Remote services (HTTP)

| Method | Path | Native route | Repository | Contract / test |
|--------|------|--------------|------------|-----------------|
| GET | `/api/communicate/status` | `RemoteServicesScreen` (Cabin tab) | `fetchCommunicateStatus` | `remote_services_contract_test.dart` |
| GET/POST | `/api/communicate/settings` | Cabin tab | `fetchCommunicateSettings`, `postCommunicateSettings` |同上 |
| POST | `/api/communicate/message` | Cabin tab (toast/dialog) | `postCommunicateMessage` |同上 |
| POST | `/api/communicate/test-speaker` | Cabin tab | `postCommunicateTestSpeaker` |同上 |
| POST | `/api/communicate/emergency-stop` | Cabin tab (confirm) | `postCommunicateEmergencyStop` |同上 |
| GET | `/api/genai/status`, `/config` | GenAI tab | `fetchGenAiStatus`, `fetchGenAiConfig` |同上 |
| POST | `/api/genai/chat` | GenAI tab | `postGenAiChat` |同上 |
| POST | `/api/genai/test` | GenAI tab | `postGenAiTest` |同上 |
| GET | `/api/genai/insights`, `/insights/dashboard` | GenAI tab | `fetchGenAiInsights`, `fetchGenAiInsightsDashboard` |同上 |
| GET | `/api/wireguard` | WireGuard tab | `fetchWireGuardStatus` |同上 |
| POST | `/api/wireguard/expose` | WireGuard tab | `postWireGuardExpose` |同上 |
| POST/DELETE | `/api/wireguard/config` | WireGuard tab (confirm) | `postWireGuardConfig`, `deleteWireGuardConfig` |同上 |

**Note:** Older `FEATURE_PARITY.md` claimed WireGuard config was HTTP-only on car; **build 24** includes upload/delete in `RemoteServicesScreen` with confirmations.

---

## 7. Remote services (WebSocket voice)

| Protocol | Path | Native route | Client | Contract / test |
|----------|------|--------------|--------|-----------------|
| PTT + PCM | `/ws/communicate` | `CommunicateVoicePanel` | `CommunicatePttClient` | `communicate_ptt_protocol_test.dart` + `voice_ws_mock_servers.dart` |
| Cabin listen | `/ws/cabin-audio` | `CommunicateVoicePanel` toggle | `CabinAudioClient` | same (test audio sink) |
| GenAI voice | `/ws/genai?lang=&token=` | `GenAiVoicePanel` | `GenAiVoiceClient` | same (fixture mic) |

**Limits:** CI uses fixture PCM/mic; no live mic/speaker latency proof. GenAI upstream provider on vehicle not mocked beyond protocol. **iOS:** no `PcmAudioPlugin` / playback plugin.

---

## 8. Integrations hub (user-facing families)

| Family | Native route | Key repository methods | UI coverage | Contract |
|--------|--------------|------------------------|-------------|----------|
| Automations | `AutomationsFamilyScreen` | list, create, test, delete, `setAutomationMode` | List + create + menu test/delete; mode localized | `extended_services_contract_test.dart` |
| Parking | `ParkingFamilyScreen` | status, config, sessions, delete session | Toggle + session cards |同上 |
| Trips | `TripsFamilyScreen` | list, summary, delete | Summary card + trip list (timestamps localized) |同上 |
| Audio library | `AudioLibraryFamilyScreen` | list, play, stop | Play/stop per clip |同上 |
| GenAI tools | `GenAiToolsFamilyScreen` | routines GET/config POST, `executeGenAiAction`, incidents **list** | Routines switch + single demo execute; incident list read-only |同上 |
| Telegram | `TelegramFamilyScreen` | status, preferences, owner clear | Pairing prefs + clear (confirm); **no** outbound send from app |同上 |
| Platform | `PlatformConnectorsScreen` | ABRP status/config/token delete, MQTT CRUD, community import | Forms + confirms |同上 |
| Advanced diagnostics | `DiagnosticsHubScreen` | see §9 | Warned entry from hub + settings | partial in contract |

**repoOnly (extended HTTP — no dedicated UI):**

| Endpoint group | Repository | Gap |
|----------------|------------|-----|
| `/api/automations/schema`, `state`, `settings` | `fetchAutomationSchema` (etc.) | No schema browser or settings editor |
| PUT `/api/automations/automation/{id}` | not exposed | No edit-automation form |
| `/api/parking/.../signage` | — | No signage UI |
| `/api/trips/{id}` GET, `/api/trips/config`, `bootstrap` | — | No trip detail / config screens |
| `/api/telegram/pin` | — | No pin entry flow |
| `/api/genai/routines/decision`, POST incidents create | `decideGenAiRoutine`, `createGenAiIncident` | No accept/reject routine UI; no create-incident form |
| `/api/launcher/v1/*`, `/api/bydcloud/status`, `/api/mqtt/telemetry` | fetch methods exist | Not shown on platform screen (ABRP/MQTT/community only) |
| `/api/audio/avas-state` | endpoint constant | No AVAS panel |

---

## 9. Advanced diagnostics & RoadSense

| Method | Path | Native route | Repository | Notes |
|--------|------|--------------|------------|-------|
| GET | `/api/debug/seat/read` | `SeatDebugScreen` | `readSeatDebug` | Key/value card |
| GET | `/api/logs/available` | `LogsDiagnosticScreen` | `fetchLogsAvailable` | |
| POST | `/api/logs/upload` | Logs (confirm) | `uploadLogDaemon` | No live upload in CI |
| GET | `/api/debug/car-property/*` | `CarPropertyDebugScreen` | status + get by key | Read-only UI |
| GET | `/api/debug/adas/*` | `AdasDebugScreen` | resolve + read | Read-only |
| GET | `/api/debug/light/resolve` | `LightDebugScreen` | resolve | Read-only |
| GET | `/api/debug/remote-key` | `RemoteKeyDebugScreen` | fetch | Read-only |
| GET | `/api/debug/autoservice/status` | `AutoServiceDebugScreen` | fetch | Read-only |
| GET | `/api/roadsense/hazards` | `RoadSenseToolsScreen` | `fetchRoadSenseHazards` | List + confirm/reject |
| POST | `/api/roadsense/test-chime` | RoadSense | `postRoadSenseTestChime` | Confirm body fields |
| POST | `/api/roadsense/delete-local` | RoadSense | `postRoadSenseDeleteLocal` | Destructive confirm |
| POST | `/api/roadsense/delete-cloud` | RoadSense | `postRoadSenseDeleteCloud` | Destructive confirm |
| POST | `/api/roadsense/hazard/{id}/confirm\|reject` | RoadSense list actions | `postRoadSenseHazardVerdict` | |

**Not in companion:** interactive RoadSense **map** (GeoJSON is list-only); upstream **write** debug paths (e.g. seat write with `confirm=YES`, light writes) — read-mostly by policy.

---

## 10. Platform / hardware exceptions (honest)

| Area | Status |
|------|--------|
| Android Auto / head-unit projection | **unimplemented** — `integrationsHeadUnitNote` |
| Cluster cast / mirror / touch | **carOnly** |
| MediaCodec runtime H.264 decode | **unverified** in CI; instrumented test needs device/emulator |
| iOS voice PCM playback | **unimplemented** (Android `PcmAudioPlugin` only) |
| Production APK signing | **debug** in shipped artifact; external release signing out of scope |
| Live car / real Telegram sends | **not** validated in automation; user-triggered only on device |
| OS Dynamic Color in goldens | **not** proven — seeded `CompanionColorSchemes` in screenshot harness |

---

## 11. Contract & screenshot cross-reference

| Test file | Scope |
|-----------|--------|
| `tunnel_login_mock_test.dart` | Auth + device token |
| `vehicle_api_test.dart` | Vehicle GET plumbing |
| `ac_charge_current_limit_test.dart` | AC charge POST readback |
| `climate_schedule_mutation_test.dart` | Booking IDs |
| `command_response_test.dart` | Lock confirm semantics |
| `camera_api_contract_test.dart` | Stream URLs, Annex-B, recordings |
| `remote_services_contract_test.dart` | Communicate, GenAI, WireGuard, surveillance |
| `extended_services_contract_test.dart` | Integrations + debug + RoadSense POST fixtures |
| `communicate_ptt_protocol_test.dart` | All three voice WebSockets |
| `handler_json_shapes_test.dart` | Upstream JSON parity |
| `test/screenshot/*` | 77 visual goldens (fixture disclaimer; not live verification) |

---

## 12. Completeness conclusion (build 24)

**Delivered in the companion app:** Full primary shell (status, controls, cameras, location, settings), tunnel auth, the vehicle control/scheduling/charge/comfort surfaces listed in §3–§5, camera stream **partial** on Android, surveillance diagnostics, remote HTTP + voice WebSocket clients with native UI, integrations hub families with confirmations, and advanced diagnostics/RoadSense maintenance POSTs grouped behind warnings.

**Not claimed:** Head-unit projection, cluster cast ecosystem, HU-only audio daemon commands, full automation schema editor, trip detail/config, Telegram pin pairing UI, GenAI routine decision/incident-creation flows, launcher/BYD cloud/MQTT telemetry dashboards, RoadSense map UI, debug **write** APIs, iOS-native media/voice plugins, production code signing, or live-vehicle/hardware certification.

**APK build 24 is frozen** for this documentation pass; this file is the authoritative consolidated inventory. Shorter `IMPLEMENTATION_INVENTORY_v2.8.3.md` in the same folder is screenshot/QA-focused only.

**Machine-readable subset:** `lib/data/capabilities/companion_parity.dart` (36 rows — **under** counts full surface above).

---

*Generated for final delivery QA — build `2.8.3+24`, branch `cursor/polished-companion-ui-940e`.*
