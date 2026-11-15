#!/usr/bin/env bash
# Exit 0 if yash-srivastava/Overdrive-release has a newer non-debug APK than WEB_SOURCE.json.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json, re, sys, urllib.request, zipfile, io, hashlib

REPO = "yash-srivastava/Overdrive-release"
cur_path = "app/src/main/assets/WEB_SOURCE.json"
cur = json.loads(open(cur_path).read())

def get(url):
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json"})
    return json.load(urllib.request.urlopen(req))

rels = get(f"https://api.github.com/repos/{REPO}/releases?per_page=30")
best = None
for r in rels:
    for a in r.get("assets", []):
        name = a["name"]
        if name.endswith(".apk") and "debug" not in name.lower():
            if best is None or a["updated_at"] > best[1]["updated_at"]:
                best = (r, a)
if not best:
    print("No upstream release APK found", file=sys.stderr)
    sys.exit(1)

r, a = best
url = a["browser_download_url"]
data = urllib.request.urlopen(url).read()
apk_sha = hashlib.sha256(data).hexdigest()

version_name = None
version_code = None
m = re.search(r"-v([\d.]+)\.apk$", a["name"])
if m:
    version_name = m.group(1)

try:
    z = zipfile.ZipFile(io.BytesIO(data))
    manifest = z.read("AndroidManifest.xml")
    # Binary XML: versionCode / versionName appear as UTF-16-like strings in many builds.
    text = manifest.decode("utf-8", errors="ignore")
    m_code = re.search(r"versionCode[^\d]*(\d{2,6})", text)
    m_name = re.search(r"versionName[^\d]*([\d.]+)", text)
    if m_code:
        version_code = int(m_code.group(1))
    if m_name and not version_name:
        version_name = m_name.group(1)
except Exception:
    pass

upstream = {
    "tag": r["tag_name"],
    "asset": a["name"],
    "uploaded": a["updated_at"],
    "url": url,
    "apk_sha256": apk_sha,
    "versionName": version_name,
    "versionCode": version_code,
}

cur_code = int(cur.get("versionCode") or 0)
up_code = int(upstream.get("versionCode") or 0)
cur_sha = cur.get("apk_sha256")
up_sha = upstream["apk_sha256"]

newer = False
if up_code > cur_code:
    newer = True
elif up_code == cur_code and up_sha != cur_sha:
    newer = True
elif up_code == 0 and up_sha != cur_sha:
    newer = True

print(json.dumps({"current": cur, "upstream": upstream, "newer": newer}, indent=2))
sys.exit(0 if newer else 2)
PY