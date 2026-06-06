#!/usr/bin/env bash
# MD external oracle gate — validates md_oracle.toml schema and driver paths.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

MD_ORACLE="$ROOT/benchmarks/competitive/md_oracle.toml"
WARN_DAYS="${LI_HPC_COMPETITIVE_REVIEW_DAYS:-90}"

li_phase "MD external oracle registry"
[[ -f "$MD_ORACLE" ]] || { li_fail "missing $MD_ORACLE"; exit 1; }

export MD_ORACLE WARN_DAYS ROOT
python3 - <<'PY'
from __future__ import annotations

import os
import sys
from datetime import date
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

root = Path(os.environ["ROOT"])
path = Path(os.environ["MD_ORACLE"])
warn_days = int(os.environ["WARN_DAYS"])
data = tomllib.loads(path.read_text())

required = (
    "id",
    "incumbent",
    "csv_lang",
    "oracle",
    "compare_metric",
    "reference",
    "driver",
    "status",
    "last_reviewed",
)
valid_status = {"stub", "active", "retired"}
errors: list[str] = []
warnings: list[str] = []

rows = data.get("oracle")
if not isinstance(rows, list) or not rows:
    errors.append("md_oracle: [[oracle]] must be a non-empty array")

ids: set[str] = set()
for i, row in enumerate(rows or []):
    if not isinstance(row, dict):
        errors.append(f"oracle[{i}]: not a table")
        continue
    oid = row.get("id", "")
    for key in required:
        if key not in row:
            errors.append(f"{oid or i}: missing field {key}")
    if oid in ids:
        errors.append(f"duplicate oracle id: {oid}")
    ids.add(oid)
    if row.get("oracle") != "external_binary":
        errors.append(f"{oid}: oracle must be external_binary")
    status = row.get("status", "")
    if status not in valid_status:
        errors.append(f"{oid}: invalid status {status!r}")
    driver = row.get("driver", "")
    if driver and not (root / driver).is_file():
        errors.append(f"{oid}: driver missing at {driver}")
    input_stub = row.get("input_stub", "")
    if input_stub and not (root / input_stub).is_file():
        errors.append(f"{oid}: input_stub missing at {input_stub}")
    lr = row.get("last_reviewed", "")
    try:
        reviewed = date.fromisoformat(str(lr))
        age = (date.today() - reviewed).days
        if age > warn_days:
            warnings.append(f"{oid}: last_reviewed {lr} is {age}d old")
    except ValueError:
        errors.append(f"{oid}: last_reviewed must be YYYY-MM-DD, got {lr!r}")

harness = data.get("harness")
if isinstance(harness, dict):
    for key in ("script", "gate_script", "li_test"):
        rel = harness.get(key, "")
        if rel and not (root / rel).is_file():
            errors.append(f"harness.{key} missing at {rel}")

for w in warnings:
    print(f"warn: {w}", file=sys.stderr)
for e in errors:
    print(f"error: {e}", file=sys.stderr)
sys.exit(1 if errors else 0)
PY
rc=$?
if [[ "$rc" -ne 0 ]]; then
  li_gate_fail "MD external oracle registry"
  exit "$rc"
fi
li_gate_ok "MD external oracle registry"
exit 0
