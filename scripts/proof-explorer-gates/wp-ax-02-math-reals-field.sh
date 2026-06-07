#!/usr/bin/env bash
# WP-AX-02: reals_field.li — four field-law contracts with statement-aligned ensures.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import sys
from pathlib import Path

path = Path("proof-db/math/axioms/reals_field.li")
syms = [
    "proof_db_real_add_comm",
    "proof_db_real_add_assoc",
    "proof_db_real_mul_distrib",
    "proof_db_real_mul_one",
]
text = path.read_text(encoding="utf-8")
fail = 0
for sym in syms:
    if f"def {sym}" not in text:
        print(f"wp-ax-02: missing def {sym}", file=sys.stderr)
        fail = 1
if "ensures result == b + a" not in text:
    print("wp-ax-02: add_comm ensures mismatch", file=sys.stderr)
    fail = 1
if fail:
    sys.exit(1)
print("wp-ax-02-math-reals-field: OK")
PY
