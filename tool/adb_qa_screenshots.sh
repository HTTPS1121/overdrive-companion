#!/usr/bin/env bash
set -euo pipefail
SERIAL="${ANDROID_SERIAL:-emulator-5554}"
OUT="${1:-/cursor/stores/self/artifacts/rebuild-v1/final/emulator}"
PKG=com.https1121.overdrive.companion
ACTIVITY=com.https1121.overdrive.companion.MainActivity
mkdir -p "$OUT"
adb -s "$SERIAL" wait-for-device

dump_ui() {
  adb -s "$SERIAL" shell uiautomator dump /sdcard/od_ui.xml >/dev/null
  adb -s "$SERIAL" pull /sdcard/od_ui.xml /tmp/od_ui.xml >/dev/null
}

tap_text() {
  local text="$1"
  dump_ui
  python3 - "$text" <<'PY'
import re, sys, xml.etree.ElementTree as ET
text = sys.argv[1]
root = ET.parse('/tmp/od_ui.xml').getroot()
for node in root.iter('node'):
    texts = (node.attrib.get('text') or '', node.attrib.get('content-desc') or '')
    if any(text in t for t in texts if t):
        b = node.attrib.get('bounds','')
        m = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', b)
        if m:
            x1,y1,x2,y2 = map(int, m.groups())
            print((x1+x2)//2, (y1+y2)//2)
            sys.exit(0)
sys.exit(1)
PY
}

snap() {
  adb -s "$SERIAL" exec-out screencap -p > "$OUT/$1.png"
  echo "snap $1"
}

tap_label() {
  read -r x y < <(tap_text "$1")
  adb -s "$SERIAL" shell input tap "$x" "$y"
}

adb -s "$SERIAL" shell am force-stop "$PKG" || true
adb -s "$SERIAL" shell am start -n "$PKG/$ACTIVITY"
sleep 5
snap 01_login

tap_label 'כניסה לדמו'
sleep 2
snap 02_home

tap_label 'נעילה'
sleep 1
snap 07_confirm_lock
tap_label 'ביטול'
sleep 1

tap_label 'פרופיל'
sleep 1
snap 08_profile
adb -s "$SERIAL" shell input keyevent 4
sleep 1

tap_label 'תפריט מסך'
sleep 1
snap 09_menu
adb -s "$SERIAL" shell input keyevent 4
sleep 1

for label in מצלמות הקלטות נסיעות עוד; do
  tap_label "$label"
  sleep 2
  case "$label" in
    מצלמות) snap 03_camera ;;
    הקלטות) snap 04_recordings ;;
    נסיעות) snap 05_trip ;;
    עוד) snap 06_more ;;
  esac
done

echo "Screenshots in $OUT"
