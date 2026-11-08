# Overdrive Companion — feature parity (2.1)

Source of truth (read-only): [HTTPS1121/Overdrive-release](https://github.com/HTTPS1121/Overdrive-release) `main`, especially `VehicleControlApiHandler.java` and PWA `vehicle-control.html` panels.

## Implemented in companion (via tunnel)

| Method | Path | UI |
|--------|------|-----|
| POST | `/auth/token` | Setup / Settings |
| GET | `/auth/status` | Connection test |
| GET | `/api/vehicle/state` | Status (LTR metrics for units) |
| GET | `/api/vehicle/cloud-status` | Status |
| GET | `/api/gps` | Location tab + status summary |
| POST | `/api/vehicle/lock` / `unlock` / `trunk` / `window` / `flash` | Controls |
| POST | `/api/vehicle/climate` / `lights` | Controls |
| POST | `/api/vehicle/find-car` | Controls (find car) |
| GET/POST | `/api/vehicle/climate-schedule` | Schedules → climate |
| GET/POST | `/api/vehicle/charging-schedule` | Schedules → charging |
| POST | `/api/vehicle/seat` | Comfort → seats |
| GET/POST | `/api/vehicle/adas` | Comfort → media & safety |
| POST | `/api/vehicle/media` | Comfort → brightness / volume |
| POST | `/api/vehicle/setting` | Comfort → ADAS toggles |
| GET | `/api/vehicle/charge-cap` | Repository + fixtures (dedicated UI TBD) |

## Phone-relevant gaps (documented only — not shown in Settings UI)

Cluster / system-only flows: `power-on/off`, `remote-access`, `surveillance`, `genai`, `dev-view`, `communicate`, `wireguard`, full 3D vehicle model, some cloud-only media paths.

Authoritative matrix for automation: `lib/data/capabilities/companion_parity.dart` (not exposed in the primary Settings screen).

## Test evidence (2.1.0)

- `flutter test` — 23 tests: contracts, widgets, fixture integration, **v2.1** golden screenshots only (`test/screenshot/goldens/v2.1/`).
- Versioned screenshot artifacts: `/opt/cursor/artifacts/v2.1-0/screenshots/` (light + dark representative tabs: status, controls, location, schedules, comfort, settings).
- **Not validated:** physical device install, live Atto 3, real tunnel command actuation (QA was cert/manifest comparison only).

## Signing / install-over notes

| Build | Cert SHA-256 (signer) | Install-over |
|-------|------------------------|--------------|
| 1.1.2 / 2.1.0 debug | `0d1b4493974f41eaa061f2f6a4f8f5cc44f0417582b64185a6189fa8cf932956` | Same lineage — upgrade in place when signatures match |
| stage1 (legacy) | `c869d2fa2ff2faf36cfa7e33abefedaee288b71f1bb67a6f12ff778ed161c644` | **Incompatible** — uninstall stage1 before installing current companion |

APK in CI/agent builds is verified with `apksigner verify` on the build VM (v2 scheme).

## Production policy

- No embedded mock / demo mode in release UI.
- Fixtures live under `test/` and `fixtures/` for tests only.
