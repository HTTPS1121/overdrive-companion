# Overdrive Companion — feature parity (2.4.0)

**Authoritative server source (vendored):** `tools/parity-ref/.../VehicleControlApiHandler.java` from [HTTPS1121/Overdrive-release](https://github.com/HTTPS1121/Overdrive-release) `main`. **PWA:** `vehicle-control.js`.

**Matrix:** `lib/data/capabilities/companion_parity.dart`. **Contract tests:** `test/contract/handler_json_shapes_test.dart`, `test/contract/ac_charge_current_limit_test.dart`.

## Implemented (tunnel)

| Path | UI |
|------|-----|
| Auth + `/api/vehicle/state`, `/cloud-status`, `/api/gps` | מצב, מיקום |
| Lock/unlock/trunk/window/flash/find-car/climate/lights | שליטה → פקודות |
| `POST /api/vehicle/power-on` \| `power-off` | שליטה → פקודות → הדלקה וכיבוי (אישור, חסימת נסיעה ב-UI) |
| `POST /api/vehicle/battery-heat` `{enabled}` | שליטה → פקודות → חימום סוללה (`batteryHeat` מ-state) |
| `POST /api/vehicle/system` `{target:screenshot, display:0\|1}` | שליטה → פקודות → צילום מסכים (אישור) |
| Climate/charging schedules, seat, adas, setting, media | שליטה → sub-tabs |
| `GET/POST /api/vehicle/charge-cap` | שליטה → טעינה |
| `GET/POST /api/vehicle/ac-charge-current-limit` `{state:1..5}` | שליטה → טעינה (segmented; `supported`/`available` מהשרת) |

Navigation: **4** bottom items (מצב \| שליטה \| מיקום \| הגדרות), RTL `NavigationBar`.

## Not on phone client (specific reasons)

| Path | Why omitted |
|------|-------------|
| `POST /api/vehicle/system` targets other than `screenshot` (home/back/recents/move_display) | Shell navigation on HU — not companion flows beyond captured screenshot |
| `POST /api/vehicle/cluster-cast`, `cluster-stop`, `cluster-touch`, … | Cluster projection / mirror controllers on HU |
| `GET /api/vehicle/cluster-apps` | Launcher list for cluster cast |
| `POST /api/vehicle/play-audio`, `stop-audio`, `speak`, `message` | Voice daemon on HU |
| `remote-access.html` / WireGuard UI | **No tunnel mutation** from companion |
| `POST /api/system/ivi-reboot` | Factory/service |
| `POST /api/vehicle/genai`, `dev-view`, `communicate` | HU dev panels |
| PWA 3D model (`/api/models/*`) | GLB on HU |

## JSON contracts

- Climate schedule GET: `bookings.listInfo[]`, `mainSettingTemp` + `timeSpan`; `bookingId` always string.
- AC charge current: GET `{success,supported,available,state,label}`; POST `{state:1..5}` with readback (`VehicleControlApiHandler` §4161–4226).
- Battery heat POST: `{enabled: bool}`; state GET may include `batteryHeat: bool` when cloud read succeeds.

## Tests & evidence

- `flutter test` — contract, widget (`extended_controls`, `controls_confirm`), screenshots **v2.4**.
- Artifacts: **`/cursor/stores/self/artifacts/v2.4-0/`**
- **No live car / device install** verified.

## Signing

Signer SHA-256 debug keystore: `0d1b4493…932956` (unchanged lineage).
