# OverDrive Companion (Android WebView shell)

**עברית (תמצית)** | [English](#english)

אפליקציית Android קלה שעוטפת את ממשק ה-Web של OverDrive מהמכונית: WebView מקומי עם נכסי `assets/web/`, הורדות/העלאות native, Material You ותג offline.

- הקוד הראשי ב־`app/`.
- גרסת Flutter ישנה נשארת ב־[`legacy/flutter/`](legacy/flutter/) (לא מפותחת כאן).

### גרסאות

| מקור | משמעות |
|------|--------|
| `app/src/main/assets/WEB_SOURCE.json` | גרסת שחרור ה-head-unit של OverDrive שמוטמעת באפליקציה (`versionName`, `versionCode`) |
| `app/shell_patch.txt` | מונה תיקונים של המעטפת בלבד (0 = זהה מספרית לשחרור הרכב; 1 → `61.1.1`, 2 → `61.1.2`, …) |

- `versionName` = שם השחרור מהרכב, או `שם.patch` אם רק המעטפת השתנתה.
- `versionCode` = `upstreamVersionCode * 100 + patch` (חייב לעלות תמיד; מעל ההתקנה הקיימת).

לצפייה בגרסה המחושבת: `tools/print-version.sh`.

### עדכון UI מהמפתח

```bash
tools/update-web-assets.sh          # השחרור האחרון (לא debug) מ־yash-srivastava/Overdrive-release
tools/update-web-assets.sh --main     # ענף main של אותו ריפו (נדיר)
```

אחרי שינוי web בלבד: הגדל את `app/shell_patch.txt` ודחוף ל־`main` (ייבנה שחרור חתום ב־CI).

ב־GitHub Actions: הרץ workflow **Update bundled OverDrive web UI** (`workflow_dispatch` בלבד — **ללא cron**) כדי למשוך שחרור upstream חדש; הוא מאפס את `shell_patch.txt` ל־0 ודוחף, ואז **Release companion APK** מפרסם APK.

### בנייה מקומית

דרוש JDK 17+ ו־Android SDK. חתימת release מקומית (אופציונלי): קבצים תחת `signing/` או משתני סביבה `ANDROID_KEYSTORE_*` (כמו ב־CI).

```bash
./gradlew :app:assembleRelease
```

שחרורים חתומים רשמיים מתפרסמים אוטומטית ב־CI עם סודות `ANDROID_KEYSTORE_*` ב־GitHub.

---

## English

Native Android **WebView shell** for the developer’s OverDrive web UI (same bundled `assets/web/` as the head-unit release APK), plus native download/upload, Material You theming, and an offline indicator.

- Main app: `app/`.
- Older **Flutter** experiment: [`legacy/flutter/`](legacy/flutter/) (history preserved; not the active app).

### Versioning

Companion versions mirror the **bundled OverDrive car release**, not an arbitrary app semver:

1. `WEB_SOURCE.json` — upstream `versionName` / `versionCode` from the APK you bundled.
2. `app/shell_patch.txt` — shell-only patch index (`0` = same number as the car build; `1` → `61.1.1`, etc.).

Derived in Gradle:

- `versionName` = upstream name, or `name.patch` when only the shell changed.
- `versionCode` = `upstreamVersionCode * 100 + patch` (monotonic; must stay above installed builds).

Run `tools/print-version.sh` to print the effective values.

### Refresh web assets

```bash
tools/update-web-assets.sh
```

To pull a newer **GitHub Release** from `yash-srivastava/Overdrive-release`, use the **Update bundled OverDrive web UI** workflow manually (no schedule). It resets `shell_patch.txt` to `0` and pushes; **Release companion APK** on `main` publishes a signed APK and GitHub Release `v<versionName>`.

Shell-only fixes: bump `app/shell_patch.txt` and push to `main`.

### Build

```bash
./gradlew :app:assembleRelease
```

Official signed releases are built in GitHub Actions (`release.yml` on push to `main`).