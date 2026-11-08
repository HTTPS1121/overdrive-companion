# Overdrive source reference & capability inventory

**Authoritative upstream:** [yash-srivastava/Overdrive-release](https://github.com/yash-srivastava/Overdrive-release)  
**Inspected ref:** `4807e94389de38feca3a8f8582e811a6c63eb2a2` (2026-11-07)  
**Companion only:** `HTTPS1121/overdrive-companion` (no car/upstream writes).

## Auth (login.html + AuthApiHandler)

| Step | Upstream | Companion 2.6 |
|------|----------|---------------|
| Device ID | `GET /auth/status` | Connection form refresh |
| Token | `POST /auth/token` `{token: deviceId-code}` | Composed + legacy full token |
| API JWT | `Authorization: Bearer` | All authenticated GET/POST |
| Live WS | `wss://host/ws?token=JWT` binary Annex-B H.264 | **Android** OkHttp WS + MediaCodec texture |

## HTTP parity matrix

| Handler | Key routes | Companion |
|---------|------------|-----------|
| VehicleControlApiHandler | `/api/vehicle/*` | Controls hub + extended |
| StreamingApiHandler | `/api/stream/*`, view modes 0–6, quality | Cameras: HTTP + **native preview** |
| RecordingsApiHandler | list, `/video/id/{hex}`, `/thumb/id/{hex}`, DELETE id | List, play (`video_player`+JWT), download bytes |
| SurveillanceApiHandler | status, config GET/POST, enable/disable, `/snapshot/{q}` | UI + snapshot dialog |
| GpsApiHandler | `/api/gps` | Location tab |
| WireGuard / Remote access | car tunnel / HU pairing | **Not phone scope** (documented) |
| GenAI `/ws/genai*` | voice/chat on HU | **Not implemented** (no phone tunnel contract) |
| `/ws/communicate`, cabin-audio | HU realtime | **HU-only** |

## Implemented in 2.6 (fixture-tested)

- Native H.264 live view (Android): reconnect backoff, queue depth 60, keyframe-aware drop policy (mirrors `StreamFrameDropPolicy` intent).
- Recording playback via `/video/id/` with bearer headers; download to app documents.
- Surveillance config load/save (sensitivity POST), enable/disable, quadrant snapshots.
- System l10n: nav, connection, cameras, stream phases, status hero, errors (en/he).
- Login parity retained; auth-before-persist.

## Genuinely unavailable without car hardware / HU binaries

- OEM encoder binding when stream daemon offline (needs BYD HAL on vehicle).
- `/api/surveillance/heatmap`, screen-deterrent upload, impact POST calibration — API present upstream; companion exposes core config/snapshot only (expand in-app as needed).
- GenAI voice WebSocket sessions (separate protocol from `/ws` video).
- WireGuard peer provisioning on phone (car-side daemon).

## Compatibility notes

- `bookingId` string decimal; unknown JSON tolerated.
- Recording identity prefers 32-hex `id` when present (RecordingsIndex).
- Older servers: hide controls when `success`/`supported` false.
