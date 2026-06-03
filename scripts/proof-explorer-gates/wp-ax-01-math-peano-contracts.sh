#!/usr/bin/env bash
# WP-AX-01: Peano/order axioms — one Li file per catalog row; non-trivial ensures.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import re
import sys
from pathlib import Path

root = Path(".")
expected = {
    "M-AX-PEANO-ZERO-NOT-SUCC": "proof-db/math/axioms/peano_zero_not_succ.li",
    "M-AX-PEANO-SUCC-INJ": "proof-db/math/axioms/peano_succ_injective.li",
    "M-AX-PEANO-IND": "proof-db/math/axioms/peano_induction.li",
    "M-AX-ORDER-TRICHOTOMY": "proof-db/math/axioms/order_trichotomy_nat.li",
    "M-AX-ORDER-ANTISYM": "proof-db/math/axioms/order_antisym.li",
}
toml = (root / "docs/verification/proof-database/entries/math-axioms.toml").read_text(encoding="utf-8")
fail = 0
for eid, rel in expected.items():
    p = root / rel
    if not p.is_file():
        print(f"wp-ax-01: missing {rel}", file=sys.stderr)
        fail = 1
        continue
    if f'id = "{eid}"' not in toml or rel not in toml:
        print(f"wp-ax-01: catalog missing {eid} -> {rel}", file=sys.stderr)
        fail = 1
    text = p.read_text(encoding="utf-8")
    if "proof_db_" not in text:
        print(f"wp-ax-01: no proof_db_* def in {rel}", file=sys.stderr)
        fail = 1
    ensures = [ln.strip() for ln in text.splitlines() if ln.strip().startswith("ensures")]
    nontrivial = [e for e in ensures if e != "ensures result == 0"]
    if not nontrivial:
        print(f"wp-ax-01: only trivial ensures in {rel}", file=sys.stderr)
        fail = 1
legacy = root / "proof-db/math/axioms/peano_order.li"
if legacy.is_file():
    print("wp-ax-01: peano_order.li should be split (remove legacy bundle)", file=sys.stderr)
    fail = 1
if fail:
    sys.exit(1)
print("wp-ax-01-math-peano-contracts: OK")
PY
