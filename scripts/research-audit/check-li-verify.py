#!/usr/bin/env python3
"""Check at least one claim reached li_open or li_proved (Phase 3 WP-LV)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CLAIMS_ROOT = ROOT / "proof-db" / "research-claims"
LI_STATUSES = {"li_proved", "li_open"}


def load_jsonl(path: Path) -> list[dict]:
    if not path.is_file():
        return []
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def main() -> int:
    found = 0
    for prob in CLAIMS_ROOT.iterdir() if CLAIMS_ROOT.is_dir() else []:
        if not prob.is_dir():
            continue
        for c in load_jsonl(prob / "claims.jsonl"):
            if c.get("epistemic_status") in LI_STATUSES:
                found += 1
    if found < 1:
        print("wp-li-verify-claims: no li_open/li_proved claims yet", file=sys.stderr)
        return 1
    print(f"wp-li-verify-claims: OK ({found} Li-classified claims)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
