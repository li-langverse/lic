#!/usr/bin/env bash
# Phase7 slice — >=3 research problems touched in sweep log or claim ledgers.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json
from pathlib import Path

ROOT = Path(".")
LOG = ROOT / "data/proof-explorer-loop/proof-sweep-log.jsonl"
CLAIMS = ROOT / "proof-db/research-claims"

problems: set[str] = set()

if CLAIMS.is_dir():
    for d in sorted(CLAIMS.iterdir()):
        if not d.is_dir():
            continue
        claims = d / "claims.jsonl"
        if claims.is_file() and any(
            ln.strip() for ln in claims.read_text(encoding="utf-8").splitlines()
        ):
            problems.add(d.name)

if LOG.is_file():
    for line in LOG.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        row = json.loads(line)
        if row.get("source") != "catalog":
            continue
        eid = str(row.get("id", ""))
        if eid.startswith("E-"):
            parts = eid.split("-")
            if len(parts) >= 2 and parts[1]:
                problems.add(f"{parts[0]}-{parts[1]}")

if len(problems) < 3:
    raise SystemExit(
        f"wp-proof-sweep-research: only {len(problems)} problems "
        f"(want >=3): {sorted(problems)}"
    )
sample = ", ".join(sorted(problems)[:12])
print(f"wp-proof-sweep-research: OK ({len(problems)} problems: {sample})")
PY
