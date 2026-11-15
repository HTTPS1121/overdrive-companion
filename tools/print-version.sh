#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json
from pathlib import Path

patch = int(Path("app/shell_patch.txt").read_text().strip())
web = json.loads(Path("app/src/main/assets/WEB_SOURCE.json").read_text())
upstream_code = int(web["versionCode"])
upstream_name = web["versionName"]
version_code = upstream_code * 100 + patch
version_name = upstream_name if patch == 0 else f"{upstream_name}.{patch}"
print(f"versionName={version_name}")
print(f"versionCode={version_code}")
PY