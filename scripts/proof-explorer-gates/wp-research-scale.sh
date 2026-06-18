#!/usr/bin/env bash
# WP-RS-01 — ≥3 research problems with claim ledgers + compare reports.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json
from pathlib import Path

claims_root = Path("proof-db/research-claims")
if not claims_root.is_dir():
    raise SystemExit("wp-research-scale: missing proof-db/research-claims")

qualified = []
for problem_dir in sorted(claims_root.iterdir()):
    if not problem_dir.is_dir():
        continue
    claims_file = problem_dir / "claims.jsonl"
    if not claims_file.is_file():
        continue
    n_claims = sum(1 for line in claims_file.read_text(encoding="utf-8").splitlines() if line.strip())
    if n_claims < 10:
        continue
    compare = Path(f"data/research-audit/{problem_dir.name}/compare-report.json")
    if not compare.is_file():
        continue
    qualified.append(problem_dir.name)

if len(qualified) < 3:
    raise SystemExit(f"wp-research-scale: only {len(qualified)} qualified problems (want >=3): {qualified}")
print(f"wp-research-scale: OK ({len(qualified)} problems: {', '.join(qualified)})")
PY
