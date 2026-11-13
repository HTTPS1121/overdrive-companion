# SERVER_TEST.md — 3.1.2+40 (mock-only CI)

## Verified on local `MockOverdriveServer`

| Area | Test / evidence |
|------|-----------------|
| Auth `/auth/status`, `/auth/token` | `connection_mock_test.dart` |
| 401 wrong access code → `אימות נדחה. בדוק את קוד הגישה.` | `connection_mock_test.dart`, `hebrew_api_test.dart` |
| Vehicle refresh offline (stale data, no throw) | `offline_refresh_test.dart` |
| 501/404 command Hebrew failure | `hebrew_api_test.dart` (404); lock mock unsupported (prior builds) |
| Recording list + `/video/id/…` JWT bytes | `recording_video_test.dart` |
| Trips `GET /api/trips` parse | mock returns sample trip; UI on Trip tab |

## Still requires real car / device QA

- Live camera HLS/WebRTC playback
- Real recording thumbnails from `/thumb/id/…`
- Full trip telemetry/detail (`/api/trips/{id}/telemetry`, GPS)
- SD/USB storage stats on Recordings header
- All vehicle commands against live HAL

No automated test in this build contacts a production vehicle or tunnel.
