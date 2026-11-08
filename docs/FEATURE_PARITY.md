# Overdrive Companion — feature parity (2.0)

Source of truth (read-only): [HTTPS1121/Overdrive-release](https://github.com/HTTPS1121/Overdrive-release) `main`, especially `VehicleControlApiHandler.java` and PWA `vehicle-control.html` panels.

## Implemented in companion (via tunnel)

| Method | Path | UI |
|--------|------|-----|
| POST | `/auth/token` | Setup / Settings |
| GET | `/auth/status` | Connection test |
| GET | `/api/vehicle/state` | Status |
| GET | `/api/vehicle/cloud-status` | Status |
| GET | `/api/gps` | Location tab |
| POST | `/api/vehicle/lock` | Controls |
| POST | `/api/vehicle/unlock` | Controls |
| POST | `/api/vehicle/trunk` | Controls |
| POST | `/api/vehicle/window` | Controls |
| POST | `/api/vehicle/flash` | Controls |
| POST | `/api/vehicle/climate` | Controls |
| POST | `/api/vehicle/lights` | (reading light via climate path subset — steering heat uses climate) |

## Not implemented (explicit — no fake UI)

PWA panels / server routes not wired in 2.0: `find-car`, `climate-schedule`, `seat`, `charging-schedule`, `charge-cap`, `power-on/off`, `adas`, `media`, `setting`, `battery-heat`, `remote-access`, `surveillance`, `genai`, `dev-view`, `communicate`, `wireguard`, etc.

See in-app list: Settings → **יכולות לעומת שרת** (`companion_parity.dart`).

## Test evidence

- `flutter test` — contract + widget + fixture integration + golden screenshots.
- Goldens: unconfigured setup, offline configured, fixture-connected status, settings (no production demo).
- **Not validated:** live Atto 3, real tunnel, command actuation on vehicle hardware.

## Blockers for full PWA parity

- Large surface area on head unit (3D model, seats UI, charging schedules, ADAS, remote access) — each needs dedicated screens and server capability probes.
- Some endpoints are SDK_ONLY or CLOUD_ONLY; companion must surface server errors, not simulate success.

## Production policy

- No embedded mock / demo mode in release UI.
- Fixtures live under `test/` and `fixtures/` for tests only.
