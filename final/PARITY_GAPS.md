# PARITY_GAPS — 3.1.1+39 vs overdrive-chosen.html + Overdrive-release

Reference HTML: `overdrive-chosen.html` (design tokens).

## Closed in 3.1.1

- Offline refresh: stale vehicle banner + last-updated label; sheets/player dismissed on refresh failure
- Recordings: removed `הדמיה` scenes; server thumb or neutral placeholder; player uses `/video/id/…` + JWT (`video_player`)
- Camera selector: 60×126 car + HTML hotspot offsets (incl. DVR `top:18px; left:62%`)
- Recordings filter/type rows: RTL scroll-to-start (`OdRtlScrollRow`)
- Trips: wired read-only `GET /api/trips?days=14&limit=30` when server returns data

## Remaining

- **Live cameras:** stream pane is status text only (no decoded live video)
- **Recordings chrome:** calendar, OEM DVR chip, hardcoded storage bar — not from `/api/recordings/stats`
- **Recording player:** quad switch changes label only (single video file per event); download not implemented
- **DVR hotspot:** selects id 6 (no dedicated server action yet)
- **Trips depth:** no detail/telemetry/GPS/map (server has `/api/trips/{id}/…`; companion lists summaries only)
- **Home “היום בתנועה”** mini-rows still placeholder copy (not trip API)
- **More / climate / windows** controls not wired to server

## Trips API note

Upstream **Overdrive-release** exposes `/api/trips` (+ bootstrap, summary, telemetry, etc.) via `TripApiHandler.java`. Companion 3.1.1 consumes the list endpoint only.
