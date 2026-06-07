#!/usr/bin/env python3
"""Check multi-model review coverage for research claims (Phase 3 WP-MR)."""
from __future__ import annotations

import json
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CLAIMS_ROOT = ROOT / "proof-db" / "research-claims"
MIN_REVIEWERS = 2


def load_jsonl(path: Path) -> list[dict]:
    if not path.is_file():
        return []
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line:
            rows.append(json.loads(line))
    return rows


def main() -> int:
    if not CLAIMS_ROOT.is_dir():
        print("wp-multi-review: no research-claims dir yet (OK during bootstrap)", file=sys.stderr)
        return 1

    problems = [p for p in CLAIMS_ROOT.iterdir() if p.is_dir()]
    if not problems:
        print("wp-multi-review: no problem dirs with claims", file=sys.stderr)
        return 1

    fail = 0
    for prob in problems:
        claims = load_jsonl(prob / "claims.jsonl")
        reviews = load_jsonl(prob / "reviews.jsonl")
        if not claims:
            continue
        by_claim: dict[str, set[str]] = defaultdict(set)
        for r in reviews:
            cid = r.get("claim_id")
            model = r.get("reviewer_model")
            if cid and model:
                by_claim[cid].add(model)
        for c in claims:
            cid = c.get("claim_id")
            if not cid:
                continue
            n = len(by_claim.get(cid, set()))
            if n < MIN_REVIEWERS:
                print(f"wp-multi-review: {prob.name}/{cid} has {n} reviewers (want >={MIN_REVIEWERS})", file=sys.stderr)
                fail = 1

    if fail:
        return 1
    print("wp-multi-review: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
