#!/usr/bin/env bash
# Smoke: agent entry manifest generation (Vision-LLM ship gate).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GEN="$ROOT/scripts/gen-li-agent-manifest.sh"
OUT_JSON="$ROOT/li-agent.json"
FRAGMENT="$ROOT/.cursor/AGENTS.generated.md"

fail() {
  echo "gen_li_agent_manifest_smoke: $*" >&2
  exit 1
}

[[ -x "$GEN" ]] || chmod +x "$GEN"
"$GEN"

[[ -f "$OUT_JSON" ]] || fail "missing $OUT_JSON"
[[ -f "$FRAGMENT" ]] || fail "missing $FRAGMENT"

grep -q '"name": "li-lic"' "$OUT_JSON" || fail "bad name in li-agent.json"
grep -q '"schema": "docs/schemas/diagnostic-v1.json"' "$OUT_JSON" || fail "missing diagnostics schema"
grep -q '"tests_agent_slice"' "$OUT_JSON" || fail "missing tests_agent_slice command"
grep -q 'li-tests/agent-manifest.json' "$OUT_JSON" || fail "missing tests manifest path"

python3 - "$OUT_JSON" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1]))
assert doc["version"] == 1
assert doc["source"] == "docs/ecosystem/li-agent-manifest.toml"
cmds = doc["commands"]
for key in ("check", "check_json", "diagnose", "build", "verify", "tests", "tests_agent_slice"):
    assert key in cmds, key
assert doc["diagnostics"]["schema"].endswith("diagnostic-v1.json")
assert doc["tests_manifest"]["schema"] == "li-tests-agent-manifest-v1"
PY

grep -q 'lic check' "$FRAGMENT" || fail "AGENTS.generated.md missing check command"
grep -q 'diagnostic-v1' "$FRAGMENT" || fail "AGENTS.generated.md missing schema"

echo "gen_li_agent_manifest_smoke: ok"
