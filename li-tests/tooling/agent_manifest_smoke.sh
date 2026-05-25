#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
chmod +x "$ROOT/scripts/export-li-tests-agent-slice.sh"
"$ROOT/scripts/export-li-tests-agent-slice.sh"

OUT="$ROOT/li-tests/agent-manifest.json"
grep -q '"schema": "li-tests-agent-manifest-v1"' "$OUT" || {
  echo "agent_manifest_smoke: bad schema" >&2
  exit 1
}
python3 - "$OUT" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1]))
assert doc["count"] == len(doc["tests"])
assert doc["count"] > 100
PY
echo "agent_manifest_smoke: ok"
