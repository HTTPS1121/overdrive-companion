# Overdrive Companion — feature parity (2.2.0)

**Source evidence:** `lib/data/capabilities/companion_parity.dart` (machine-readable matrix). Reference server: [HTTPS1121/Overdrive-release](https://github.com/HTTPS1121/Overdrive-release) `VehicleControlApiHandler.java` + PWA `vehicle-control.html`.

## Implemented (tunnel phone client)

| Method | Path | UI surface |
|--------|------|------------|
| POST | `/auth/token` | Setup, Settings |
| GET | `/auth/status` | Connection test |
| GET | `/api/vehicle/state` | מצב (LTR metrics) |
| GET | `/api/vehicle/cloud-status` | מצב |
| GET | `/api/gps` | מיקום + תקציר במצב (קואורדינטות, מפה, ניווט) |
| POST | lock/unlock/trunk/window/flash/find-car/climate/lights | שליטה → פקודות (+ אישור לפקודות מסוכנות) |
| GET/POST | `/api/vehicle/climate-schedule` | שליטה → תזמונים (רשימה + יצירה/עריכה/מחיקה) |
| GET/POST | `/api/vehicle/charging-schedule` | שליטה → תזמונים |
| POST | `/api/vehicle/start-charging` | תזמון טעינה |
| GET/POST | `/api/vehicle/charge-cap` | שליטה → טעינה |
| POST | `/api/vehicle/seat` | שליטה → נוחות → מושבים |
| GET/POST | `/api/vehicle/adas`, `/api/vehicle/setting`, `/api/vehicle/media` | שליטה → נוחות |

**Navigation:** 4 bottom destinations (מצב | שליטה | מיקום | הגדרות). תזמונים / נוחות / מגבלת טעינה תחת **שליטה** (M3 ≤5).

## Not implemented (with reason — see matrix `carOnlyReason`)

| Path | Reason |
|------|--------|
| POST `/api/vehicle/system` | Head-unit navigation / camera UI |
| POST `/api/vehicle/cluster-cast` | Cluster projection only |
| GET `/api/vehicle/cluster-apps` | Cluster projection only |

Additional PWA/server routes **not wired** in companion (no fake UI): `power-on/off`, `battery-heat`, `remote-access`, `surveillance`, `genai`, `dev-view`, `communicate`, `wireguard`, 3D model panel, etc.

## Tests (fixture-only — no live car)

- `flutter test` — contracts, integration mock, confirm dialogs, **25** cases including `test/widget/controls_confirm_test.dart`.
- Goldens: `test/screenshot/goldens/v2.2/` only (not legacy `goldens/` root).

## Validation limits

- **No on-device install verified** in agent QA (cert/manifest comparison only).
- Tunnel actuation on real Atto 3 not exercised.

## Signing

| Build | Signer SHA-256 | Notes |
|-------|----------------|-------|
| 1.1.2 / 2.2.0 release | `0d1b4493974f41eaa061f2f6a4f8f5cc44f0417582b64185a6189fa8cf932956` | Debug keystore on release build (test distribution) |
| stage1 legacy | `c869d2fa2ff2faf36cfa7e33abefedaee288b71f1bb67a6f12ff778ed161c644` | **Not** install-over compatible |

Release APK: `application:debuggable=false` (not a debug build variant).
