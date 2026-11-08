# Overdrive source reference & capability inventory

**Authoritative upstream:** [yash-srivastava/Overdrive-release](https://github.com/yash-srivastava/Overdrive-release)  
**Inspected ref:** `4807e94389de38feca3a8f8582e811a6c63eb2a2` (2026-11-07) — `main`  
**User fork (parity vendored):** [HTTPS1121/Overdrive-release](https://github.com/HTTPS1121/Overdrive-release) — **same SHA** at inspection (no lag vs upstream).

**Companion repo only:** `HTTPS1121/overdrive-companion` — no writes to car repos.

## Remote tunnel auth (login.html + AuthApiHandler)

| Step | Contract |
|------|----------|
| 1 | `GET /auth/status` (public) → `deviceId` string |
| 2 | User enters **access code** only (≥8 chars, lowercase on wire) |
| 3 | `POST /auth/token` body `{ "token": "<deviceId>-<accessCode>" }` → `jwt` |
| 4 | API calls: `Authorization: Bearer <jwt>`; tunnels may need `?token=` on WebSocket |

Companion setup mirrors steps 1–3 (`ConnectionForm`). Legacy full token in secure storage still supported.

## HTTP handlers (native companion scope)

| Area | Paths (upstream handlers) | Companion |
|------|---------------------------|-----------|
| Vehicle | `VehicleControlApiHandler` `/api/vehicle/*` | שליטה tabs + extended power/battery/screenshot/AC current |
| Auth | `AuthApiHandler` | Setup + settings |
| GPS | `GpsApiHandler` `/api/gps` | מיקום |
| Stream | `StreamingApiHandler` `/api/stream/*`, blind-spot `/api/stream/bs/*` | מצלמות: status/enable/disable/view; **live video** via `wss://<host>/ws?token=<jwt>` (H.264, `stream.js`) |
| Recordings | `RecordingsApiHandler` `/api/recordings`, `/api/events/*` | List UI; download/delete not yet wired |
| Surveillance | `SurveillanceApiHandler` `/api/surveillance/*` | Status read; config/enable UI pending |
| Remote access | `RemoteAccessApiHandler` `/api/remote-access` | Proximity — **HU pairing**, not phone tunnel setup |
| WireGuard | `WireGuardApiHandler` `/api/wireguard` | Car-side tunnel to home; not phone companion URL |

## Verified blockers (no live car in agent env)

| Feature | Blocker | Source evidence |
|---------|---------|-----------------|
| Live camera preview | H.264 over WebSocket `/ws` + platform decoder; JWT query param | `stream.js` `connectWebSocket`, `StreamingApiHandler.java` |
| Recording playback | Binary/media routes + auth; large file streaming | `RecordingsApiHandler.java`, file paths under car storage |
| Surveillance config POST | Large surface (heatmaps, snapshots); needs staged UI | `SurveillanceApiHandler.java` |
| Cluster cast / audio / GenAI | HU daemons, not tunnel JSON phone flows | Handler list + existing `FEATURE_PARITY.md` |

## Compatibility

- Treat unknown JSON fields as optional; `supported`/`available`/`bookingsUnavailable` honored.
- Do not send `bookingId` as JSON number (use string).
- Older servers without `batteryHeat` / AC current: UI hides controls when field/`supported` false.
