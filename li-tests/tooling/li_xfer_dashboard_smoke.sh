#!/usr/bin/env bash
# WP-PAR-92 — dashboard xfer_sec / elided_copies CSV columns.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_xfer_dashboard_smoke"
CSV="$ROOT/build/li_xfer_dashboard_smoke.csv"
MAIN="$ROOT/build/li_xfer_dashboard_main.c"

CC="${CC:-clang-22}"
mkdir -p "$(dirname "$OUT")"
cat > "$MAIN" <<'EOF'
#include "li_xfer_plan.h"
#include <stdio.h>

const LiXferPlan __li_xfer_plan = {
    LI_XFER_PLAN_MAGIC,
    LI_XFER_PLAN_VERSION,
    2u,
    0u,
    0u,
    0u,
};

int main(void) {
  li_xfer_elide_copy();
  li_xfer_elide_copy();
  li_xfer_set_last_xfer_sec(0.00125);
  printf("%.6f %u\n", li_xfer_last_xfer_sec(), li_xfer_last_elided_copies());
  return 0;
}
EOF

"$CC" -std=c11 -O2 -Wall -Wextra -D_DEFAULT_SOURCE \
  -I"$RT" \
  "$MAIN" \
  "$RT/li_xfer_plan.c" \
  "$RT/li_dpar.c" \
  "$RT/li_rt_hetero.c" \
  "$RT/li_rt.c" \
  -pthread -lm \
  -o "$OUT"

read -r xfer_sec elided < <("$OUT")
python3 - "$CSV" "$xfer_sec" "$elided" <<'PY'
import csv
import sys
from pathlib import Path

out = Path(sys.argv[1])
xfer_sec = sys.argv[2]
elided = sys.argv[3]
header = ["benchmark", "lang", "metric", "value", "unit", "xfer_sec", "elided_copies"]
rows = [
    {
        "benchmark": "xfer_plan_smoke",
        "lang": "li_parallel",
        "metric": "wall_time",
        "value": "0.001",
        "unit": "s",
        "xfer_sec": xfer_sec,
        "elided_copies": elided,
    },
    {
        "benchmark": "xfer_plan_smoke",
        "lang": "li_parallel",
        "metric": "xfer_sec",
        "value": xfer_sec,
        "unit": "s",
        "xfer_sec": xfer_sec,
        "elided_copies": elided,
    },
    {
        "benchmark": "xfer_plan_smoke",
        "lang": "li_parallel",
        "metric": "elided_copies",
        "value": elided,
        "unit": "count",
        "xfer_sec": xfer_sec,
        "elided_copies": elided,
    },
]
out.parent.mkdir(parents=True, exist_ok=True)
with out.open("w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=header)
    w.writeheader()
    w.writerows(rows)

with out.open(newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    cols = reader.fieldnames or []
    if "xfer_sec" not in cols or "elided_copies" not in cols:
        print("li_xfer_dashboard_smoke: missing dashboard columns", file=sys.stderr)
        sys.exit(1)
    metrics = {row["metric"] for row in reader}
    if "xfer_sec" not in metrics or "elided_copies" not in metrics:
        print("li_xfer_dashboard_smoke: missing xfer_sec/elided_copies metric rows", file=sys.stderr)
        sys.exit(1)
print(f"li_xfer_dashboard_smoke: ok ({out})")
PY

echo "li_xfer_dashboard_smoke: ok"
