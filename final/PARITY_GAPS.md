# PARITY_GAPS — 3.1.3+41 vs overdrive-chosen.html + Overdrive-release

Reference HTML: `overdrive-chosen.html` (design tokens).

## Closed in 3.1.1–3.1.3 (real-data policy)

- Offline refresh, recordings list/player, 401 wording, trips tab, camera diagram, RTL chips, login feedback
- **Home:** vehicle status grid + range footer from `GET /api/vehicle/state` only; «היום בתנועה» from today's `GET /api/trips` or neutral empty copy
- **Recordings chrome:** storage bar + today chip + OEM DVR label from `GET /api/recordings/stats` only (hidden when absent)
- **More:** vehicle comfort controls (climate/windows) via server POST + confirm sheet; other rows → `לא נתמך עדיין בשרת`
- **Player:** multi-angle switch only when server sends multiple cameras; download → unsupported message
- Hardcoded demo metrics removed from `lib/ui` (31.2 GB, 90% charge cap, tyre PSI placeholders, etc.)

## Remaining

- **Live cameras:** stream pane is status text only (no decoded live video)
- **Recordings:** calendar date-picker not on server — today count chip only when stats provide `totalTodayCount`
- **Recording player:** download not implemented; multi-angle needs server `cameras[]` per event
- **DVR hotspot:** selects id 6 (no dedicated server action yet)
- **Trips depth:** no detail/telemetry/GPS/map (server has `/api/trips/{id}/…`; companion lists summaries only)
- **Home parking events:** no list API wired — neutral empty copy only
- **More catalog:** docs/descriptions only except «בקרות הרכב» comfort actions

## Trips API note

Upstream **Overdrive-release** exposes `/api/trips` (+ bootstrap, summary, telemetry, etc.) via `TripApiHandler.java`. Companion 3.1.3 consumes list + today's slice on home.

## Recordings stats note

`RecordingsApiHandler.getStorageStats()` → `GET /api/recordings/stats` (usage %, formatted sizes, `totalTodayCount`, optional OEM/DVR labels when server sends them).
