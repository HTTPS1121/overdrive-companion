#!/usr/bin/env bash
# Write app/UPSTREAM_BUNDLE_NOTES.md comparing previous WEB_SOURCE + web tree to current.
# Usage: tools/summarize-bundle-update.sh <previous_WEB_SOURCE.json> [previous_web_dir]
set -euo pipefail
cd "$(dirname "$0")/.."
PREV_META="${1:?}"
PREV_WEB="${2:-}"
OUT="app/UPSTREAM_BUNDLE_NOTES.md"
CUR_META="app/src/main/assets/WEB_SOURCE.json"
CUR_WEB="app/src/main/assets/web"
python3 - "$PREV_META" "$PREV_WEB" "$CUR_META" "$CUR_WEB" "$OUT" <<'PY'
import json, os, subprocess, sys, urllib.request
prev_meta_p, prev_web, cur_meta_p, cur_web, out_p = sys.argv[1:6]
prev = json.load(open(prev_meta_p)) if os.path.isfile(prev_meta_p) else {}
cur = json.load(open(cur_meta_p))


def walk(root):
    files = {}
    if not os.path.isdir(root):
        return files
    for dp, _, names in os.walk(root):
        for n in names:
            rel = os.path.relpath(os.path.join(dp, n), root).replace("\\", "/")
            files[rel] = os.path.getsize(os.path.join(dp, n))
    return files


pw = walk(prev_web) if prev_web else {}
if not pw:
    import subprocess
    try:
        out = subprocess.check_output(
            ["git", "diff", "--name-status", "main", "--", "app/src/main/assets/web"], text=True
        )
        for line in out.splitlines():
            parts = line.split("\t")
            if len(parts) < 2:
                continue
            st, path = parts[0], parts[-1]
            rel = path.split("assets/web/", 1)[-1] if "assets/web/" in path else path
            if st == "D":
                pw[rel] = 0
    except Exception:
        pass
cw = walk(cur_web)
added = sorted(set(cw) - set(pw))
removed = sorted(set(pw) - set(cw))
changed = sorted(k for k in set(cw) & set(pw) if cw[k] != pw.get(k))

lines = [
    f"# Bundled OverDrive web UI: {prev.get('versionName', '?')} → {cur.get('versionName', cur.get('tag', '?'))}",
    "",
    f"- Previous: `{prev.get('asset', prev.get('tag', '?'))}` (apk_sha256 `{prev.get('apk_sha256', '')[:12]}…`)",
    f"- Current: `{cur.get('asset', cur.get('tag', '?'))}` (apk_sha256 `{cur.get('apk_sha256', '')[:12]}…`)",
    f"- Upstream versionCode: **{cur.get('versionCode', '?')}**",
    "",
    "## Asset diff",
    f"- Added ({len(added)})",
]
for p in added[:80]:
    lines.append(f"  - `{p}`")
if len(added) > 80:
    lines.append(f"  - … and {len(added) - 80} more")
lines += [f"- Removed ({len(removed)})"]
for p in removed[:80]:
    lines.append(f"  - `{p}`")
if len(removed) > 80:
    lines.append(f"  - … and {len(removed) - 80} more")
lines += [f"- Changed size ({len(changed)})"]
for p in changed[:60]:
    lines.append(f"  - `{p}` ({pw.get(p)} → {cw.get(p)} bytes)")
if len(changed) > 60:
    lines.append(f"  - … and {len(changed) - 60} more")

def changelog_excerpt(tag):
    try:
        url = f"https://api.github.com/repos/yash-srivastava/Overdrive-release/releases/tags/{tag}"
        req = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json", "User-Agent": "od-companion"})
        rel = json.load(urllib.request.urlopen(req, timeout=20))
        body = (rel.get("body") or "").strip()
        if not body:
            return None
        if len(body) > 3500:
            body = body[:3500] + "\n\n… (truncated)"
        return body
    except Exception:
        return None

tag = cur.get("tag")
if tag:
    cl = changelog_excerpt(tag)
    if cl:
        lines += ["", "## Upstream release notes (`" + tag + "`)", "", cl]

text = "\n".join(lines) + "\n"
open(out_p, "w").write(text)
# One-line subject for commits
print(f"chore: bundle OverDrive {cur.get('versionName', '?')} ({cur.get('asset', '')})")
print("---BODY---")
print(text)
PY