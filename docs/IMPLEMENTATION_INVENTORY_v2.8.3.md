# Implementation inventory (2.8.3+23)

## Screenshot QA (v2.8.3)

| Item | Value |
|------|-------|
| Golden root | `test/screenshot/goldens/v2.8.3` |
| Total PNGs | **77** (17 core `0x_`/`1x_` … `13_` + **60** `int_*`) |
| Harness | `test/screenshot/screenshot_harness.dart` — `ensureBundledFontsLoaded`, `PhoneViewport` (390×844), `companionLightTheme` / `companionDarkTheme` |
| Integration routes | Full production `Scaffold` screens; voice via **`RemoteServicesScreen`** (tabs, load, margins) |
| Fixture banner | `screenshotFixtureDisclaimer` — does not replace readable UI |

Artifact dir: `artifacts/v2.8.3/` (`app-release.apk`, `RELEASE_MANIFEST_v2.8.3.json`, `screenshots/`).

## Advanced diagnostics (retained, grouped)

- Primary **Integrations hub** lists user-facing families only; **Advanced diagnostics** is a separate warned card.
- `DiagnosticsHubScreen`: warning banner + RoadSense + seat/logs/car-property/ADAS/light/remote-key/autoservice.
- Readouts use `KeyValueReadoutCard` (not raw JSON dumps).

## RoadSense / debug POSTs

Same as 2.8.3 repository coverage; contract tests unchanged. No live vehicle uploads in CI.

## Voice lifecycle

`RemoteServicesScreen` + panels; screenshot harness loads communicate/GenAI status from fixture before capture.

## MediaCodec

JVM `AnnexBUtilsTest` ✅. Instrumented `MediaCodecAnnexBInstrumentedTest` — **not run** in Cloud Agent (no connected device/emulator).

## Signing

Debug release keystore retained (`releaseSigningDebugNote`).

## Tests

**136** `flutter test` (after screenshot regeneration).
