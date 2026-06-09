#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
chmod +x "$ROOT/scripts/export-li-tests-agent-slice.sh" \
  "$ROOT/scripts/gen-li-agent-manifest.sh"

"$ROOT/scripts/export-li-tests-agent-slice.sh"
"$ROOT/scripts/gen-li-agent-manifest.sh"

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
suites = doc["suites"]
assert isinstance(suites, list) and len(suites) >= 5
assert sum(s["count"] for s in suites) == doc["count"]
assert all("name" in s and "count" in s for s in suites)
PY

AGENT_JSON="$ROOT/li-agent.json"
grep -q '"name": "li-lic"' "$AGENT_JSON" || {
  echo "agent_manifest_smoke: missing li-agent.json name" >&2
  exit 1
}
grep -q '"path": "li-tests/agent-manifest.json"' "$AGENT_JSON" || {
  echo "agent_manifest_smoke: li-agent.json missing tests_manifest path" >&2
  exit 1
}
python3 - "$AGENT_JSON" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1]))
assert doc["tests_manifest"]["schema"] == "li-tests-agent-manifest-v1"
assert "check_json" in doc["commands"]
assert "diagnose" in doc["commands"]
assert doc["diagnostics"]["schema"] == "docs/schemas/diagnostic-v1.json"
PY

FRAGMENT="$ROOT/.cursor/AGENTS.generated.md"
grep -q 'lic check.*--format=json' "$FRAGMENT" || {
  echo "agent_manifest_smoke: missing AGENTS.generated.md check_json hint" >&2
  exit 1
}

echo "agent_manifest_smoke: ok"
