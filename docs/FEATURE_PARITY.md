# Overdrive Companion — feature parity (2.3.0)

**Authoritative server source (vendored for audit):** `tools/parity-ref/.../VehicleControlApiHandler.java` from [HTTPS1121/Overdrive-release](https://github.com/HTTPS1121/Overdrive-release) `main`. **PWA:** `vehicle-control.js`.

**Matrix:** `lib/data/capabilities/companion_parity.dart`. **Contract tests:** `test/contract/handler_json_shapes_test.dart` (shapes from handler, not invented fixtures).

## Implemented (tunnel)

| Path | UI |
|------|-----|
| Auth + `/api/vehicle/state`, `/cloud-status`, `/api/gps` | מצב, מיקום |
| Lock/unlock/trunk/window/flash/find-car/climate/lights | שליטה → פקודות |
| Climate/charging schedules, charge-cap, seat, adas, setting, media | שליטה → sub-tabs |

Navigation: **4** bottom items (מצב \| שליטה \| מיקום \| הגדרות), RTL `NavigationBar`, `alwaysShow` labels.

## Planned phone-remote (handler exposes; companion wiring in progress)

| Path | Handler routing | Companion status |
|------|-----------------|------------------|
| `POST /api/vehicle/power-on` \| `power-off` | SDK_ONLY; parked+stationary guard | **Not in UI yet** — requires confirmation + driving gate |
| `POST /api/vehicle/battery-heat` | CLOUD_ONLY `{enabled:bool}` | **Not in UI yet** — state from `/api/vehicle/state` `batteryHeat` |
| `POST /api/vehicle/system` `{target:screenshot\|...}` | UID-2000 shell; surveillance capture | **Not in UI yet** — explicit confirm per capture |
| `GET/POST /api/vehicle/ac-charge-current-limit` | SDK trim-dependent | **Not wired** |

## Not on phone client (specific reasons)

| Path | Why omitted |
|------|-------------|
| `POST /api/vehicle/cluster-cast`, `cluster-stop`, `cluster-touch`, … | Requires in-car cluster projection / mirror controllers (`ClusterCast`, `ClusterMirrorController`) — not a tunnel JSON command from phone |
| `GET /api/vehicle/cluster-apps` | Lists head-unit launcher apps for cluster cast — no phone UX |
| `POST /api/vehicle/play-audio`, `stop-audio`, `speak`, `message` | Voice/audio daemon on HU; not remote companion flows |
| `remote-access.html` / WireGuard UI | Separate PWA page; changes tunnel credentials — **no tunnel mutation** from companion without dedicated remote-access API review |
| `POST /api/system/ivi-reboot` | Factory/service reboot — not offered in companion |
| `POST /api/vehicle/genai`, `dev-view`, `communicate` | Head-unit dev / GenAI panels |
| PWA 3D model (`/api/models/*`) | GLB asset pipeline on HU; not phone control surface |

## JSON contract fixes (2.3)

- Climate schedule GET: `bookings.listInfo[]`, `mainSettingTemp` (raw)+`timeSpan` → °C/minutes (`ClimateBooking.fromCloudListEntry`).
- `bookingsUnavailable` / `emptyBookingsMayBeStale` honoured in schedules UI.
- Seat POST: requires full `driverHeat`/`driverVent`/`passengerHeat`/`passengerVent` when sending composite state (handler lines 2582–2590).

## Tests & evidence

- `flutter test` — includes `app_shell_nav_test`, `controls_confirm_test`, `handler_json_shapes_test`, screenshot harness **v2.3** (`test/screenshot/goldens/v2.3/`).
- Artifacts: **`/cursor/stores/self/artifacts/v2.3-0/screenshots/`** (2.2.0 folder unchanged).
- Screenshots: nav `selectedIndex` asserted; async panels settled; map tile skipped in screenshot mode (coordinates + nav button shown).
- **No live car / device install** verified.

## Signing (unchanged from 2.2 release lineage)

Signer SHA-256 debug keystore: `0d1b4493…932956`. Stage1 `c869d2fa…` incompatible install-over.
