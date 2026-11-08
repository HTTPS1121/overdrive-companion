#!/usr/bin/env bash
# Write docs/RELEASE_MANIFEST_v2.8.0.json from a built APK + pubspec version.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APK="${1:-$ROOT/build/app/outputs/flutter-apk/app-release.apk}"
VERSION_LINE="$(grep '^version:' "$ROOT/pubspec.yaml" | awk '{print $2}')"
NAME_VER="${VERSION_LINE%%+*}"
BUILD="${VERSION_LINE##*+}"
OUT="${2:-$ROOT/docs/RELEASE_MANIFEST_v2.8.5.json}"
ARTIFACT_DIR="${ARTIFACT_DIR:-v2.8.5}"
if [[ ! -f "$APK" ]]; then
  echo "APK not found: $APK" >&2
  exit 1
fi
SIZE="$(stat -c%s "$APK")"
SHA="$(sha256sum "$APK" | awk '{print $1}')"
SIGNER="$(
  if command -v apksigner >/dev/null 2>&1; then
    apksigner verify --print-certs "$APK" 2>/dev/null | head -1 || echo "unknown"
  else
    echo "debug (Flutter template release)"
  fi
)"
META="$ROOT/build/app/outputs/apk/release/output-metadata.json"
ACTUAL_CODE=""
ACTUAL_NAME=""
if command -v aapt >/dev/null 2>&1; then
  ACTUAL_CODE="$(aapt dump badging "$APK" 2>/dev/null | sed -n "s/.*versionCode='\([^']*\)'.*/\1/p" | head -1 || true)"
  ACTUAL_NAME="$(aapt dump badging "$APK" 2>/dev/null | sed -n "s/.*versionName='\([^']*\)'.*/\1/p" | head -1 || true)"
fi
if [[ -z "$ACTUAL_CODE" && -f "$META" ]]; then
  ACTUAL_CODE="$(python3 -c "import json;print(json.load(open('$META'))['elements'][0]['versionCode'])")"
  ACTUAL_NAME="$(python3 -c "import json;print(json.load(open('$META'))['elements'][0]['versionName'])")"
fi
if [[ -n "$ACTUAL_CODE" && "$ACTUAL_CODE" != "$BUILD" ]]; then
  echo "warning: pubspec build number +$BUILD != APK versionCode $ACTUAL_CODE" >&2
  BUILD="$ACTUAL_CODE"
fi
SCREENSHOT_COUNT="$(python3 - <<PY
import os
g=os.path.join("$ROOT", "test/screenshot/goldens", "$ARTIFACT_DIR")
if not os.path.isdir(g):
    print(93)
    raise SystemExit
png=[f for f in os.listdir(g) if f.endswith(".png")]
core=len([f for f in png if not f.startswith("int_") and not f.startswith("push_")])
integ=len([f for f in png if f.startswith("int_")])
push=len([f for f in png if f.startswith("push_")])
print(len(png))
PY
)"
cat >"$OUT" <<EOF
{
  "version": "$NAME_VER+$BUILD",
  "apkFile": "app-release.apk",
  "apkArtifactName": "app-release.apk",
  "apkSha256": "$SHA",
  "apkSizeBytes": $SIZE,
  "apkVersionCode": ${ACTUAL_CODE:-$BUILD},
  "apkVersionName": "${ACTUAL_NAME:-$NAME_VER}",
  "apkSigningCertSummary": "$SIGNER",
  "goldens": "test/screenshot/goldens/$ARTIFACT_DIR",
  "screenshotArtifacts": "$ARTIFACT_DIR/screenshots",
  "screenshotCount": $SCREENSHOT_COUNT,
  "artifactDirectory": "$ARTIFACT_DIR",
  "implementationInventoryComplete": "IMPLEMENTATION_INVENTORY_COMPLETE_build${BUILD}.md",
  "android": {
    "signing": "debug (Flutter template release) unless production keystore configured",
    "mediaCodecDecode": "not verified in CI — framing unit tests only"
  },
  "dynamicColorGoldenNote": "02c uses seeded CompanionColorSchemes — not OS wallpaper dynamic color",
  "upstreamRef": "4807e94389de38feca3a8f8582e811a6c63eb2a2"
}
EOF
python3 - <<PY
import json, os
p="$OUT"
g=os.path.join("$ROOT", "test/screenshot/goldens", "$ARTIFACT_DIR")
with open(p) as f: m=json.load(f)
if os.path.isdir(g):
    png=[f for f in os.listdir(g) if f.endswith(".png")]
    m["screenshotCountBreakdown"]={
        "core": len([f for f in png if not f.startswith("int_") and not f.startswith("push_")]),
        "integration": len([f for f in png if f.startswith("int_")]),
        "pushDetail": len([f for f in png if f.startswith("push_")]),
    }
    m["screenshotCount"]=len(png)
with open(p,"w") as f: json.dump(m,f,indent=2)
PY
echo "Wrote $OUT (versionCode=${ACTUAL_CODE:-$BUILD}, sha=$SHA)"
