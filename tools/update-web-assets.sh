#!/usr/bin/env bash
# Refresh the bundled OverDrive web UI from the developer's project (yash-srivastava/Overdrive-release).
# Default: newest GitHub Release APK (release builds ship pages that are not yet on the public main branch).
# Usage: tools/update-web-assets.sh [--release <tag>] [--main]
set -euo pipefail
cd "$(dirname "$0")/.."
REPO=yash-srivastava/Overdrive-release
DEST=app/src/main/assets/web
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
MODE=release; TAG=""
while [ $# -gt 0 ]; do case "$1" in --main) MODE=main;; --release) TAG="$2"; shift;; esac; shift; done
if [ "$MODE" = main ]; then
  git clone -q --depth 1 --filter=blob:none --sparse "https://github.com/$REPO.git" "$WORK/repo"
  (cd "$WORK/repo" && git sparse-checkout set --no-cone /app/src/main/assets/web/ >/dev/null)
  SRC="$WORK/repo/app/src/main/assets/web"
  META=$(cd "$WORK/repo" && git log -1 --format='{"source":"main","commit":"%H","date":"%cI"}')
else
  python3 - "$REPO" "$TAG" "$WORK" <<'PY'
import json, sys, urllib.request
repo, tag, work = sys.argv[1:4]
def get(u): return json.load(urllib.request.urlopen(urllib.request.Request(u, headers={"Accept": "application/vnd.github+json"})))
rels = [get(f"https://api.github.com/repos/{repo}/releases/tags/{tag}")] if tag else get(f"https://api.github.com/repos/{repo}/releases?per_page=30")
best = None
for r in rels:
    tag = (r.get("tag_name") or "").lower()
    for a in r["assets"]:
        name = a["name"]
        if not name.endswith(".apk") or "debug" in name.lower():
            continue
        if "alpha" in tag or "alpha" in name.lower():
            continue
        if best is None or a["updated_at"] > best[1]["updated_at"]:
            best = (r, a)
r, a = best
print(f"Newest release APK: {a['name']} (tag {r['tag_name']}, uploaded {a['updated_at']})", file=sys.stderr)
urllib.request.urlretrieve(a["browser_download_url"], f"{work}/release.apk")
json.dump({"source": "release", "tag": r["tag_name"], "asset": a["name"], "uploaded": a["updated_at"], "url": a["browser_download_url"]}, open(f"{work}/meta.json", "w"))
PY
    python3 - "$WORK" <<'PY'
import hashlib, json, os, re, subprocess, sys, zipfile
work = sys.argv[1]
apk = f"{work}/release.apk"
z = zipfile.ZipFile(apk)
for n in z.namelist():
    if n.startswith("assets/web/") and not n.endswith("/"):
        out = os.path.join(work, "web", n[len("assets/web/"):])
        os.makedirs(os.path.dirname(out), exist_ok=True)
        open(out, "wb").write(z.read(n))
m = json.load(open(f"{work}/meta.json"))
m["apk_sha256"] = hashlib.sha256(open(apk, "rb").read()).hexdigest()
for cmd in ("aapt2", "aapt"):
    try:
        out = subprocess.check_output([cmd, "dump", "badging", apk], text=True, stderr=subprocess.DEVNULL)
        mc = re.search(r"versionCode='(\d+)'", out)
        mn = re.search(r"versionName='([^']+)'", out)
        if mc:
            m["versionCode"] = int(mc.group(1))
        if mn:
            m["versionName"] = mn.group(1)
        break
    except Exception:
        pass
if "versionName" not in m:
    m2 = re.search(r"-v([\d.]+)\.apk$", m.get("asset", ""))
    if m2:
        m["versionName"] = m2.group(1)
try:
    vcs = z.read("META-INF/version-control-info.textproto").decode()
    m["build_revision"] = re.search(r'revision: "([0-9a-f]+)"', vcs).group(1)
except Exception:
    pass
with open(f"{work}/meta.json", "w") as fh:
    json.dump(m, fh, indent=2)
    fh.write("\n")
PY
  SRC="$WORK/web"; META=$(cat "$WORK/meta.json")
fi
rm -rf "$DEST" && mkdir -p "$DEST" && cp -r "$SRC"/. "$DEST"/
rm -rf "$DEST/local/shared"   # duplicate copy of shared/ in some trees
echo "$META" > app/src/main/assets/WEB_SOURCE.json
echo "Bundled web UI updated: $META"; echo "Pages: $(ls "$DEST/local" | grep -c '\.html$')"
