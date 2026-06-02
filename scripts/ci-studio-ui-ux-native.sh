#!/usr/bin/env bash
# CI gate: Studio UI/UX plan loop (SDL native capture + bench registry; no full lic build).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export STUDIO_UI_UX_GATES_SKIP_BUILD=1
export LI_REPO_ROOT="$ROOT"

chmod +x scripts/studio-ui-ux-plan-gates.sh \
  scripts/studio-ui-ux-probe-capture-deps.sh \
  scripts/studio-ui-ux-check-capture-deps.sh \
  scripts/studio-ui-ux-capture-native.sh \
  deploy/studio-demo/native/capture.sh 2>/dev/null || true

STUDIO_UI_UX_CAPTURE_DEPS_STRICT=1 STUDIO_UI_UX_CAPTURE_DEPS_WARN_ONLY=0 \
  ./scripts/studio-ui-ux-check-capture-deps.sh

python3 scripts/studio-ui-ux-verify-native-capture.py

python3 - <<'PY'
import json
import sys
from pathlib import Path

meta = json.loads(
    Path("data/studio-ui-ux-plan-loop/latest-native-capture.json").read_text(encoding="utf-8")
)
if not meta.get("native_pixels"):
    print("ci-studio-ui-ux-native: native_pixels false", file=sys.stderr)
    sys.exit(1)
print("ci-studio-ui-ux-native: ok (native_pixels=true)")
PY
