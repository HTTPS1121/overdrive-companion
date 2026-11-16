# Bundled OverDrive web UI: 61.1 → 62.1

- Previous: `overdrive-release-braveheart-v61.1.apk` (apk_sha256 `327c5426f3dd…`)
- Current: `overdrive-release-braveheart-v62.1.apk` (apk_sha256 `b09acb997e59…`)
- Upstream versionCode: **210**

## Asset diff
- Added (8)
  - `shared/module-faults-dashboard.js`
  - `shared/timeline-player.js`
  - `shared/timeline-strip.js`
  - `shared/timeline-view.css`
  - `shared/timeline-view.js`
  - `shared/vendor/NOTICE.txt`
  - `shared/vendor/hls.js-LICENSE.txt`
  - `shared/vendor/hls.light.min.js`
- Removed (0)
- Changed size (24)
  - `i18n/en.json` (395664 → 401982 bytes)
  - `i18n/he.json` (508617 → 519829 bytes)
  - `local/charging.html` (131632 → 132494 bytes)
  - `local/credits.json` (6985 → 7151 bytes)
  - `local/events.html` (80317 → 93320 bytes)
  - `local/index.html` (249626 → 252258 bytes)
  - `local/live-view.html` (157552 → 158429 bytes)
  - `local/recording.html` (72275 → 72256 bytes)
  - `local/remote-access.html` (45566 → 47946 bytes)
  - `local/storage.html` (35807 → 36525 bytes)
  - `local/surveillance.html` (152182 → 152834 bytes)
  - `local/trips.html` (149932 → 151604 bytes)
  - `shared/events.js` (177191 → 184750 bytes)
  - `shared/module-faults.js` (7492 → 7557 bytes)
  - `shared/parking.js` (50708 → 51264 bytes)
  - `shared/remote-access.js` (130708 → 131960 bytes)
  - `shared/revamp.css` (61645 → 62370 bytes)
  - `shared/search.js` (38043 → 38463 bytes)
  - `shared/send-logs.js` (12776 → 12905 bytes)
  - `shared/storage-budget.js` (30104 → 30807 bytes)
  - `shared/storage.js` (57075 → 59320 bytes)
  - `shared/stream.js` (52923 → 53065 bytes)
  - `shared/surveillance.js` (320175 → 326232 bytes)
  - `shared/trips.js` (288439 → 290029 bytes)

## Upstream release notes (`braveheart`)

## 🇴🇩 Overdrive Update v62.0: Recordings Timeline, DiLink 5 Fixes & More

### ✨ New Features

- **Recordings Timeline** — Your whole day on one strip, in the car app and the browser. Drag to any moment and hit play; clips run back to back with no gaps, and notifications open right at the clip.
- **Know why it's empty** — Grey gaps tell you why nothing was recorded: Sentry off, low battery, safe zone, deleted, or no card.
- **Follow the live edge** — Playback picks up each new clip the moment it's saved.
- **Up to 8× speed** — Skim fast, or let Skip quiet driving race through drives and slow down for events.
- **Both cameras, one timeline** — 360 and factory dashcam together; switch at the same second, with lens correction on the fly.
- **Instant streaming** — The browser streams clips in small pieces, so long days start right away.
- **Impact sensor status** — See at a glance whether the parked impact sensor is working.
- **Phone priority** — Optional: a trusted phone near the car stops the key fob from locking it; the fob still works when no phone is around.
- **Lock with the key inside** — Optional: walk away with your phone and the car locks even with the key left inside, and that key can't reopen it.
- **Module faults on the Dashboard** — A warning card shows when the car reports a module fault, with a link to the details.
- **No Limit storage** — Recordings and Surveillance can use the whole card; the oldest clips go only when it's nearly full.

### ⚡ Optimizations & Fixes

- **DiLink 5** — Vehicle commands work again, and the trunk opens while the car is locked (experimental).
- **Recording** — New clips go to the SD card you chose, with cabin audio in sync.
- **Sharper alerts** — Better-quality alert photos in Telegram and web push.
- **Live View** — Works again through proxies and tunnels.
- **Quick commands** — Lock, Unlock, Flash and Find work again over Cloudflare tunnels.
- **Check for Updates** — Now on the Module Faults and Factory DVR pages too.
- **Garage signs** — Reads the small level and bay placards it used to miss.
- **Tidier pages** — Recordings filters fold behind a Filters button, Trips and Charging keep their date bar pinned, and search results show each page's icon.
- **Automations** — One stuck vehicle reading no longer holds up other automations.
- **Under the hood** — Steadier service restarts, lighter performance monitoring and motion heatmap, and translated module fault names.

---
