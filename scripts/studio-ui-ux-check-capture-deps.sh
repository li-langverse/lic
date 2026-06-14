#!/usr/bin/env bash
# Assert capture-deps probe output (issue #399 / studio-ux-16 CI capture deps).
# Runs studio-ui-ux-probe-capture-deps.sh, requires JSON on disk, soft-warns on gaps.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JSON="${STUDIO_UI_UX_CAPTURE_DEPS_JSON:-$ROOT/data/studio-ui-ux-plan-loop/latest-capture-deps.json}"
PROBE="$ROOT/scripts/studio-ui-ux-probe-capture-deps.sh"

[[ -x "$PROBE" ]] || chmod +x "$PROBE" 2>/dev/null || true
[[ -f "$PROBE" ]] || { echo "studio-ui-ux-check-capture-deps: missing probe script" >&2; exit 1; }

"$PROBE"

python3 - "$JSON" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
if not path.is_file() or path.stat().st_size == 0:
    print(f"studio-ui-ux-check-capture-deps: missing or empty {path}", file=sys.stderr)
    raise SystemExit(1)

deps = json.loads(path.read_text(encoding="utf-8"))
native = bool(deps.get("ready_for_native_capture"))
html = bool(deps.get("ready_for_html_capture"))
gaps = deps.get("gaps") or []

print(
    f"studio-ui-ux-check-capture-deps: ok schema={deps.get('schema')} "
    f"native={native} html={html} gaps={len(gaps)}"
)

strict = __import__("os").environ.get("STUDIO_UI_UX_CAPTURE_DEPS_STRICT", "0") == "1"
warn_only = __import__("os").environ.get("STUDIO_UI_UX_CAPTURE_DEPS_WARN_ONLY", "1") != "0"

if not native or not html:
    msg = []
    if not native:
        msg.append("native_capture_ready=false")
    if not html:
        msg.append("html_capture_ready=false")
    line = "studio-ui-ux-check-capture-deps: " + "; ".join(msg)
    if gaps:
        line += f" ({', '.join(gaps[:4])}{'…' if len(gaps) > 4 else ''})"
    if strict:
        print(line, file=sys.stderr)
        raise SystemExit(1)
    if warn_only:
        print(line, file=sys.stderr)
PY
