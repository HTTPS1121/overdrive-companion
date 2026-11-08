#!/usr/bin/env bash
# Ensure RELEASE_MANIFEST paths match on-disk artifact layout (v2.8.5 folder).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="${1:-$ROOT/docs/RELEASE_MANIFEST_v2.8.5.json}"
ARTIFACT_DIR="${2:-/cursor/stores/self/artifacts/v2.8.5}"
if [[ ! -d "$ARTIFACT_DIR" ]]; then
  ARTIFACT_DIR="$ROOT/artifacts/v2.8.5"
fi
export MANIFEST ARTIFACT_DIR ROOT

python3 - <<'PY'
import json, os, sys

manifest_path = os.environ["MANIFEST"]
artifact_dir = os.environ["ARTIFACT_DIR"]
repo_root = os.environ["ROOT"]
with open(manifest_path) as f:
    m = json.load(f)

errors = []
expected_dir = "v2.8.5"
if m.get("artifactDirectory") != expected_dir:
    errors.append(f"artifactDirectory must be {expected_dir}, got {m.get('artifactDirectory')!r}")
if m.get("screenshotArtifacts") != f"{expected_dir}/screenshots":
    errors.append(f"screenshotArtifacts must be {expected_dir}/screenshots")
if m.get("goldens") != f"test/screenshot/goldens/{expected_dir}":
    errors.append(f"goldens must be test/screenshot/goldens/{expected_dir}")

if m.get("implementationInventory"):
    errors.append(f"obsolete implementationInventory field: {m.get('implementationInventory')}")
complete = m.get("implementationInventoryComplete")
if not complete or not str(complete).startswith("IMPLEMENTATION_INVENTORY_COMPLETE_build"):
    errors.append("implementationInventoryComplete must be set")

apk = m.get("apkFile", "app-release.apk")
for name in (complete, apk):
    if not name:
        continue
    path = os.path.join(artifact_dir, name)
    if not os.path.isfile(path):
        errors.append(f"artifact missing: {path}")

golden_root = m.get("goldens", "")
goldens_repo = os.path.normpath(os.path.join(repo_root, golden_root))
if not os.path.isdir(goldens_repo):
    errors.append(f"golden dir missing in repo: {goldens_repo}")
manifest_copy = os.path.join(artifact_dir, os.path.basename(manifest_path))
if not os.path.isfile(manifest_copy):
    errors.append(f"artifact missing manifest copy: {manifest_copy}")

if errors:
    print("Artifact manifest validation FAILED:", file=sys.stderr)
    for e in errors:
        print(" -", e, file=sys.stderr)
    sys.exit(1)
print("Artifact manifest validation OK")
PY
