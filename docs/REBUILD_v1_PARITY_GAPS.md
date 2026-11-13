# Overdrive rebuild v1 — parity gaps (final)

Design reference: `overdrive-chosen.html` (SHA-256 `9d51550e4a62cc3a9fc34f999b678b5889e0f43fa40d95044b10ab67e0075e7a`).

## Signing (resolved policy)

- **Permanent key:** `c55757d19355e8818297da59374e6dc16ffd76696236cb0161032c78555d4d29` (Android Debug CN, PKCS12 at `android/signing/c557-debug.keystore` via git-ignored `android/key.properties`).
- Legacy `0d1b4493…932956` keystore is **lost** — installs over builds 24–29 are not expected; all v1+ rebuilds use `c557…`.

## QA capture notes

- **Emulator:** AVD `Overdrive390` 390×844, `-accel off` + SwiftShader (KVM denied on cloud VM). Boot succeeded; **System UI ANR** under load limited UIAutomator/adb navigation.
- **Flutter app captures in `final/`:** widget goldens at 390×844 logical (`flutter test` — labelled `SOURCE=widget-golden-390x844` in VERIFY.txt) unless `final/emulator/` contains adb captures.
- **HTML captures:** Puppeteer viewport 390×844 (`tool/capture_html_demo.mjs`).

## Typography & colour

- Bundled **NotoSansHebrew** vs HTML system font stack — line metrics and letter-spacing differ slightly.
- Focus ring `outline: 3px solid #e3a52c` on HTML buttons — not replicated on all Flutter controls.

## Motion

- HTML card `arrive` animation — not implemented.
- Camera `connPulse` / hotspot `hotspotPulse` — partial (fade only); hotspots not interactive.

## Illustrations

- Car side/top, parking scene, map — simplified `CustomPaint` / `path_drawing` paths, not full SVG fidelity.

## Home

- Range card content matched; energy-gradient login hero matched on login screen.
- `OdIcon` stroke SVG paths — minor join/cap deltas vs browser.
- “היום בתנועה” rows — not linked to trip/record sheets.

## Bottom navigation

- `BackdropFilter` blur without CSS `backdrop-filter: saturate(150%)`.
- Shadow colour/blur approximated (`#132f5926`, 30px).

## Cameras

- Missing: car-diagram cam hotspots, quad/all-cams, DVR hotspot, map-expanded mode, top-bar prefs/fullscreen, quality sheet.

## Recordings

- Full five filter rows (actor/severity/proximity/storage/place chips) — **placeholder strip** only; type tabs work in demo.
- Video modal, scrubber, quadrant bar, recording player — not built.
- Calendar / OEM DVR — chrome only.

## Trip / More

- Trip list / More capability rows — no detail bottom sheets from HTML `detail()` / `groups`.

## Sheets & flows

- Lock confirm + result demo flow — present.
- Profile sheet — simplified body vs HTML.
- Context menu sheet — single paragraph vs full `screenMenuExtras` list.
- Entire HTML `detail()` catalog for connection states, records, trips — not ported.

## Platform

- **iOS:** Bundle ID set; no build on Linux CI.
- **Release APK:** demo data only; `packages/overdrive_server` unused at runtime.

## Intentional scope (stage 1)

- No live tunnel, JWT, or vehicle HTTP commands.
- No WebView.
