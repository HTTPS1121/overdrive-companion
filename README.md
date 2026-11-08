# Overdrive Companion | מלווה Overdrive

Flutter Android companion for **Overdrive** (BYD Atto 3 and other BYD models). Talks to the **Overdrive HTTP server on the car** (default port **8080**) over LAN or a tunnel (Zrok, Cloudflare, Tailscale, WireGuard). This is **not** the head-unit app and **not** a WebView wrapper.

---

## English

### Stage 1 (this repo)

- Hebrew **RTL** dark automotive dashboard (לוח מחוונים / שליטה / הגדרות)
- Explicit **דמו** banner when not in live mode — never masquerades as real car data
- Onboarding: base URL, device token (encrypted storage), JWT session persistence, connection test
- **Status**: `GET /api/vehicle/state` + optional cloud/gps; stale-data warning from server `timestamp`
- **Control**: grouped actions (access, windows, climate); lock/unlock uses server `confirmation` + state readback
- **Embedded mock** (default) + optional **local HTTP mock** (`dart run tool/mock_server.dart`)

### Real Overdrive endpoints wired

| Method | Path | Use in app |
|--------|------|------------|
| GET | `/auth/status` | Connection test (public) |
| POST | `/auth/token` | `{ "token": "<device-secret>" }` -> response field **`jwt`** (not `token`) |
| GET | `/api/vehicle/state` | Status screen (SOC, range, doors, windows, climate, tyres, …) |
| GET | `/api/vehicle/cloud-status` | BYD Cloud / local remote-key health |
| GET | `/api/gps` | `location.canSpeedKmh` -> parked vs driving hint |
| POST | `/api/vehicle/lock` | Lock |
| POST | `/api/vehicle/unlock` | Unlock |
| POST | `/api/vehicle/trunk` | `{ "action": "open"\|"close" }` |
| POST | `/api/vehicle/window` | `{ "area": 0, "command": 1\|2 }`, `{ "action": "vent" }` |
| POST | `/api/vehicle/flash` | Flash lights |
| POST | `/api/vehicle/climate` | `power_on`, `power_off`, `set_temp`, `set_fan`, steering heat actions |
| POST | `/api/vehicle/lights` | `{ "target": "readingLight", "enable": true\|false }` |

Source of truth: [HTTPS1121/Overdrive-release](https://github.com/HTTPS1121/Overdrive-release) `main` (`VehicleControlApiHandler.java`, `AuthApiHandler.java`, web `login.html`).

**Version:** `1.1.0+2` (`com.https1121.overdrive.companion`). Release APK is signed with **debug keystore** until you add a release signing config (see `android/app/build.gradle.kts`).

**Screenshots (Flutter goldens, embedded mock):** `test/screenshot/goldens/*.png` — also copied to artifacts during `flutter test test/screenshot/`.

**Live car:** compile/tests and mock integration do **not** verify end-to-end operation on a real Atto 3 without your vehicle and tunnel.

**Not in stage 1** (roadmap): `find-car`, charging schedule, seat memory, streaming `/api/stream/*`, recordings, surveillance, trips, MQTT, push.

### Tunnel URL

1. Run Overdrive on the car and enable your tunnel (Zrok / Cloudflared / Tailscale / WireGuard).
2. In the app **Settings**, set base URL to the tunnel origin, e.g. `https://your-name.trycloudflare.com` or `https://car.example.com` (no trailing slash).
3. Copy the **device token** from Overdrive on the car and paste it in settings. Remote access via tunnel requires JWT (`POST /auth/token`).

LAN example: `http://192.168.x.x:8080`

### Build APK

Tested toolchain: **Flutter 3.47.9** (Dart 3.13), **JDK 17**, Android SDK **build-tools 36**.

```bash
export PATH="/path/to/flutter-347/bin:$PATH"
export ANDROID_HOME="$HOME/android-sdk"
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

APK: `build/app/outputs/flutter-apk/app-release.apk`  
Package id: `com.https1121.overdrive.companion`  
**Signing:** debug keystore (see `android/app/build.gradle.kts`) until you add release keys.

### Screenshots (portrait 390×844, real Flutter goldens)

Bundled **NotoSansHebrew** (Hebrew) + **NotoSans** (digits/Latin) + **MaterialIcons** in `assets/fonts/`.  
`flutter test test/screenshot/` renders `MainShell` and copies PNGs to `test/screenshot/goldens/`.

### Mock server (optional)

```bash
dart run tool/mock_server.dart --port 18080
# optional JWT: dart run tool/mock_server.dart --auth
```

In app: **Settings -> Mock HTTP** or use **Embedded mock** (no server process).

### Project layout

```
lib/
  core/config/          AppSettings, ConnectionMode
  data/api/             OverdriveApiClient
  data/models/          VehicleState, CloudStatus, GpsSnapshot
  data/mock/            In-memory + Shelf HTTP mock
  data/repositories/    VehicleRepository, endpoint catalog
  features/             onboarding, status, control, shell
  providers/            Riverpod
fixtures/               Sample /api/vehicle/state JSON
tool/mock_server.dart   Standalone mock HTTP server
```

### Roadmap (later stages)

1. Live cameras + `/api/stream/*`, quality, surround view  
2. Recordings browser + `/api/recordings`, events  
3. Surveillance + BYD Cloud deterrent settings  
4. Trips + `/api/trips`, charging + `/api/charging`  
5. Automations + push notifications  
6. iOS polish (project already includes `ios/`)

---

## עברית

### מה זה?

אפליקיית Flutter שמתחברת לשרת HTTP של **Overdrive** ברכב (פורט 8080 בדרך כלל), לא WebView.

### הרצה לפיתוח

```bash
flutter pub get
flutter run
```

ברירת מחדל: **דמו מובנה** — עובד בלי רכב.

### חיבור לרכב אמיתי

1. הגדרות -> **רכב / מנהרה**
2. הזן URL (Wi‑Fi: `http://IP:8080`, מנהרה: `https://…`)
3. הזן **device token** מהאפליקציה ברכב
4. **בדיקת חיבור** -> **שמירה**

### בניית APK

```bash
flutter build apk --release
```

---

## License

Independent companion project; not affiliated with Overdrive upstream. Do not commit secrets (device tokens) to git.
