#!/usr/bin/env bash
# WP-DS-01 — dot4 loop discharge or honest catalog downgrade (BUG-C-01).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

# Accept either: closed dot4 specimen verifies, or open specimen + catalog honestly target.
closed_candidates=(
  "li-tests/contracts_verify/linalg_dot4_int_loop_closed.li"
  "li-tests/math_linalg/linalg_dot4_int_loop_closed.li"
)
open_candidates=(
  "li-tests/contracts_verify/linalg_dot4_int_loop_open.li"
  "li-tests/math_linalg/linalg_dot4_int_loop_open.li"
)

resolve_lic() {
  if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
    echo "$ROOT/build/compiler/lic/lic"
    return 0
  fi
  if [[ -x "$ROOT/scripts/resolve-lic.sh" ]]; then
    "$ROOT/scripts/resolve-lic.sh" 2>/dev/null && return 0
  fi
  return 1
}

found_closed=""
for f in "${closed_candidates[@]}"; do
  if [[ -f "$f" ]]; then
    found_closed="$f"
    break
  fi
done

if [[ -n "$found_closed" ]] && LIC="$(resolve_lic)"; then
  if "$LIC" verify "$found_closed" 2>/dev/null; then
    echo "wp-discharge-dot4: OK (closed specimen verifies: $found_closed)"
    exit 0
  fi
fi

# Honest downgrade path: open specimen exists + BUG-C-01 disposition file
disposition="data/proof-explorer-loop/bug-disposition/BUG-C-01.json"
open_ok=0
for f in "${open_candidates[@]}"; do
  if [[ -f "$f" ]]; then
    open_ok=1
    break
  fi
done

if [[ "$open_ok" -eq 1 && -f "$disposition" ]]; then
  python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("data/proof-explorer-loop/bug-disposition/BUG-C-01.json").read_text())
if d.get("resolution") not in ("catalog_downgrade", "discharge_fixed"):
    raise SystemExit("wp-discharge-dot4: BUG-C-01 disposition missing resolution")
print(f"wp-discharge-dot4: OK (honest downgrade: {d.get('resolution')})")
PY
  exit 0
fi

echo "wp-discharge-dot4: BUG-C-01 unresolved — need verify pass or honest downgrade disposition" >&2
exit 1
