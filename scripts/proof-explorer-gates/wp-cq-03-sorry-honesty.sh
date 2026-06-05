#!/usr/bin/env bash
# WP-CQ-03: std_triangle_ineq_scalar honest sorry/discrepancy posture.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json
import sys
from pathlib import Path

idx = json.loads(Path("proof-db/index.json").read_text(encoding="utf-8"))
by_id = {e["id"]: e for e in idx.get("entries", [])}
tri = by_id.get("std_triangle_ineq_scalar")
dot4 = by_id.get("std_dot4_bilinear_right")
fail = 0
if not tri or tri.get("status") not in ("sorry", "open", "discrepancy"):
    print(f"wp-cq-03: std_triangle_ineq_scalar status={tri and tri.get('status')}", file=sys.stderr)
    fail = 1
if not dot4 or dot4.get("status") not in ("open", "sorry", "discrepancy"):
    print(f"wp-cq-03: std_dot4_bilinear_right status={dot4 and dot4.get('status')}", file=sys.stderr)
    fail = 1
lean = Path("proof-db/lean/ProofDB.lean").read_text(encoding="utf-8")
if "std_triangle_ineq_float_scalar" not in lean or "sorry" not in lean:
    print("wp-cq-03: ProofDB still missing sorry triangle", file=sys.stderr)
    fail = 1
if fail:
    sys.exit(1)
print("wp-cq-03-sorry-honesty: OK")
PY
