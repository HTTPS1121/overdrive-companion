# Rebuild v1 (design match — demo only)

Flutter UI rebuilt to match `overdrive-chosen.html`. Stage 1 uses `DemoVehicleRepository` only (`lib/demo/`, `kCompanionUsesDemoRepository = true`). Server auth/API isolated in `packages/overdrive_server/` (not wired to UI).

QA: `flutter analyze`, `flutter test`, goldens `test/screenshot/rebuild-v1/` at 390×844.

Artifacts (APK, HTML/app/compare screenshots, parity list): agent store `artifacts/rebuild-v1/`.

**Signing:** see `PARITY_GAPS.md` in artifacts — lineage debug keystore not present on cloud build VM.
