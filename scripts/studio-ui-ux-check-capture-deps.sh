#!/usr/bin/env bash
# studio-ux-16 — probe capture deps, assert JSON, soft-warn gaps, optional HTML smoke.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

PROBE="$ROOT/scripts/studio-ui-ux-probe-capture-deps.sh"
OUT="${STUDIO_UI_UX_CAPTURE_DEPS_JSON:-$ROOT/data/studio-ui-ux-plan-loop/latest-capture-deps.json}"
SMOKE_OUT="${STUDIO_UI_UX_HTML_SMOKE_JSON:-$ROOT/data/studio-ui-ux-plan-loop/latest-html-capture-smoke.json}"

[[ -x "$PROBE" ]] || chmod +x "$PROBE"
"$PROBE"

[[ -f "$OUT" ]] || {
  li_gate_fail "latest-capture-deps.json missing after probe"
  exit 1
}

python3 - "$OUT" <<'PY'
import json
import sys
from pathlib import Path

out = Path(sys.argv[1])
data = json.loads(out.read_text(encoding="utf-8"))
if data.get("schema") != "li_studio_capture_deps_v1":
    print(f"studio-ui-ux-check-capture-deps: bad schema in {out}", file=sys.stderr)
    sys.exit(1)
for key in ("ready_for_native_capture", "ready_for_html_capture", "deps", "gaps"):
    if key not in data:
        print(f"studio-ui-ux-check-capture-deps: missing key {key!r}", file=sys.stderr)
        sys.exit(1)
print(f"studio-ui-ux-check-capture-deps: json ok ({out})")
PY

warn_count=0
if ! python3 - "$OUT" <<'PY'
import json, sys
from pathlib import Path
d = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
sys.exit(0 if d.get("ready_for_native_capture") else 1)
PY
then
  li_warn "native_capture_ready=false — install libsdl2-dev + xvfb (see gaps in latest-capture-deps.json)"
  warn_count=$((warn_count + 1))
fi

if ! python3 - "$OUT" <<'PY'
import json, sys
from pathlib import Path
d = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
sys.exit(0 if d.get("ready_for_html_capture") else 1)
PY
then
  li_warn "html_capture_ready=false — install chromium/google-chrome for HTML mock PNG capture"
  warn_count=$((warn_count + 1))
fi

if [[ "${STUDIO_UI_UX_CHECK_CAPTURE_HTML_SMOKE:-0}" == "1" ]]; then
  li_phase "headless chrome HTML smoke"
  DEMO="$ROOT/deploy/studio-demo/screenshots"
  SMOKE_PNG="$ROOT/data/studio-ui-ux-plan-loop/html-smoke.png"
  mkdir -p "$(dirname "$SMOKE_OUT")"
  chrome=""
  if [[ -n "${CHROME:-}" ]]; then
    chrome="$CHROME"
  else
    for c in google-chrome chromium chromium-browser; do
      command -v "$c" >/dev/null 2>&1 && chrome="$c" && break
    done
  fi
  mock_html="$(ls "$DEMO"/[0-9]*.html 2>/dev/null | head -1 || true)"
  smoke_ok=false
  smoke_err=""
  if [[ -z "$chrome" ]]; then
    smoke_err="no chrome binary"
    li_warn "HTML smoke skipped — $smoke_err"
  elif [[ -z "$mock_html" ]]; then
    smoke_err="no HTML mocks in $DEMO"
    li_warn "HTML smoke skipped — $smoke_err"
  else
    timeout_sec="${STUDIO_UI_UX_CAPTURE_HTML_TIMEOUT_SEC:-45}"
    if timeout "$timeout_sec" "$chrome" --headless --disable-gpu --hide-scrollbars \
      --window-size=1920,1080 --screenshot="$SMOKE_PNG" "file://${mock_html}"; then
      if [[ -s "$SMOKE_PNG" ]]; then
        smoke_ok=true
        li_ok "HTML smoke ok → $SMOKE_PNG ($(wc -c < "$SMOKE_PNG") bytes)"
      else
        smoke_err="screenshot empty"
        li_warn "HTML smoke failed — $smoke_err"
      fi
    else
      smoke_err="chrome timeout or exit ${timeout_sec}s"
      li_warn "HTML smoke failed — $smoke_err"
    fi
  fi
  python3 - "$SMOKE_OUT" "$smoke_ok" "$smoke_err" "$mock_html" "$chrome" <<'PY'
import json, sys
from datetime import datetime, timezone
from pathlib import Path

out = Path(sys.argv[1])
ok = sys.argv[2] == "true"
payload = {
    "schema": "li_studio_html_capture_smoke_v1",
    "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "pass": ok,
    "mock_html": sys.argv[4] or None,
    "chrome_binary": sys.argv[5] or None,
    "error": sys.argv[3] or None,
}
out.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
print(f"studio-ui-ux-check-capture-deps: smoke meta -> {out}")
PY
  if [[ "$smoke_ok" != true && "${STUDIO_UI_UX_CAPTURE_DEPS_STRICT:-0}" == "1" ]]; then
    li_gate_fail "HTML smoke required but failed"
    exit 1
  fi
fi

if [[ "$warn_count" -gt 0 && "${STUDIO_UI_UX_CAPTURE_DEPS_STRICT:-0}" == "1" ]]; then
  li_gate_fail "capture deps not ready (strict mode)"
  exit 1
fi

li_ok "studio-ui-ux-check-capture-deps ($warn_count soft warning(s))"
