# Overdrive rebuild v1 — design parity gaps

Reference: `overdrive-chosen.html` (SHA-256 `9d51550e4a62cc3a9fc34f999b678b5889e0f43fa40d95044b10ab67e0075e7a`).

## Signing (blocker)

- **Required** cert SHA-256: `0d1b4493974f41eaa061f2f6a4f8f5cc44f0417582b64185a6189fa8cf932956` (Android Debug, builds 24–29).
- **Built APK** on this agent was signed with the VM default `~/.android/debug.keystore` → `c55757d19355e8818297da59374e6dc16ffd76696236cb0161032c78555d4d29`.
- The lineage keystore is **not in the repository** (gitignored `**/*.keystore`); release Gradle only sets `signingConfig = debug`, which resolves to whatever debug keystore exists on the build host.
- **Impact:** APK will **not** install over existing builds until re-signed with the original debug keystore file from the maintainer machine.

## Typography & colour

- App uses bundled **NotoSansHebrew**; HTML uses `-apple-system, BlinkMacSystemFont, Segoe UI, Arial` — metrics differ slightly (h1/h2/num sizes).
- Focus ring `outline: 3px solid #e3a52c` on HTML buttons — Flutter uses platform defaults unless focused manually.

## Motion

- HTML `@keyframes arrive` on cards — not reproduced.
- `connPulse` / `hotspotPulse` on cameras — conn dot only partially (fade); camera hotspots not interactive.

## Illustrations

- Car side/top and parking `scene` / `map` are **simplified** `CustomPaint`/`path_drawing` subsets of the HTML SVG paths (not full path fidelity).

## Home

- HTML `energy` gradient hero variant on login only; home uses `rangecard` — matched at content level.
- Quick-control icons via SVG paths — Flutter `OdIcon` stroke paths; minor stroke/join differences possible.
- `היום בתנועה` rows not wired to sheets/trip navigation.

## Bottom nav

- Glass: `BackdropFilter` blur without CSS `saturate(150%)` — frosted look slightly different.
- Nav item press states / exact shadow colour `#132f5926` approximated.

## Cameras

- No cam hotspot selector on car diagram (HTML interactive `cam-hotspot` rings).
- No quad / all-cams mode, DVR hotspot, map-expanded fullscreen, quality prefs sheet, or fullscreen expand.
- Top bar buttons (prefs/expand) omitted.

## Recordings

- Multi-row actor/severity/proximity/storage/place filter chips — **collapsed** to summary strip (horizontal type tabs + placeholder filter card).
- Video modal player, timeline scrubber, quadrant bar — not implemented.
- Calendar / OEM DVR chip — visual only.

## Trip / More

- Trip detail sheet on row tap — not wired.
- More group rows — no detail bottom sheets.

## Sheets

- Profile / menu / confirm / result flows — core confirm + result for controls present; extensive HTML `detail()` catalog not ported.

## iOS

- Bundle ID updated to `com.https1121.overdrive.companion` in `project.pbxproj`; **no iOS build** on this Linux VM.

## QA captures

- Flutter: widget goldens at 390×844 (`test/screenshot/rebuild-v1/`).
- HTML: Puppeteer at 390×844 (`artifacts/rebuild-v1/html/`).
- Side-by-side: `artifacts/rebuild-v1/compare/*_side_by_side.png` (HTML left, Flutter right).
