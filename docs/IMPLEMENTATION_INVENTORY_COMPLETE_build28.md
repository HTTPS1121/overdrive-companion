# Overdrive Companion — complete implementation inventory (build 28)

| Field | Value |
|-------|--------|
| Version | `2.8.4+28` (`versionCode` **28**) |
| APK | `app-release.apk` |
| Manifest | `RELEASE_MANIFEST_v2.8.5.json` |
| Artifact folder | **`v2.8.5/`** (goldens `test/screenshot/goldens/v2.8.5`) |
| APK SHA-256 | `88bc58bf19af55aa9ee708876be82db4f64d8d830f429abf086fe0377ee54580` |
| Tests | **161** `flutter test` |
| Screenshots | **93** PNG (17 core + 60 integration + 16 push) |

## Build 28 (narrow)

1. **Automation settings:** `activeCount` row labeled **Active automations** / **אוטומציות פעילות** (not duplicate “Engine state”). Regression: `automation_state_readout_test.dart`.
2. **Manifest hygiene:** `release_manifest_from_apk.sh` + `artifact_manifest_test.dart` + `tool/validate_artifact_manifest.sh` — paths locked to `v2.8.5`, only `implementationInventoryComplete`, no stale `v2.8.4` doc refs.

## Feature scope

Unchanged from build 27 (`IMPLEMENTATION_INVENTORY_COMPLETE_build27.md` matrix). RoadSense markers + MQTT epoch fixes retained.

## Residual gaps

Cluster touch UI, Android Auto, iOS plugins, live hardware proof, production signing.

*Do not treat build 28 as full vehicle certification — fixture/CI evidence only.*
