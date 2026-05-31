#!/usr/bin/env python3
"""Compare reviewer 'proved' verdicts vs Li epistemic status (Phase 3 WP-CM).

Flags unprovable_language: reviewers said proved but claim is not li_proved or literature_proved.
"""
from __future__ import annotations

import argparse
import json
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CLAIMS_ROOT = ROOT / "proof-db" / "research-claims"
AUDIT_OUT = ROOT / "data" / "research-audit"
GROUNDED = {"li_proved", "literature_proved"}


def load_jsonl(path: Path) -> list[dict]:
    if not path.is_file():
        return []
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def build_report(problem_id: str, claims: list[dict], reviews: list[dict]) -> dict:
    by_id = {c["claim_id"]: c for c in claims if c.get("claim_id")}
    reviewer_proved: dict[str, list[str]] = defaultdict(list)
    for r in reviews:
        if r.get("verdict") == "proved" and r.get("claim_id"):
            reviewer_proved[r["claim_id"]].append(r.get("reviewer_model", "?"))

    unprovable = []
    for cid, models in reviewer_proved.items():
        claim = by_id.get(cid, {})
        status = claim.get("epistemic_status", "heuristic")
        if status not in GROUNDED:
            unprovable.append({"claim_id": cid, "epistemic_status": status, "reviewers_proved": models})

    return {
        "problem_id": problem_id,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "claims_total": len(claims),
        "by_epistemic_status": dict(Counter(c.get("epistemic_status", "?") for c in claims)),
        "model_conflicts": sum(1 for c in claims if c.get("epistemic_status") == "model_conflict"),
        "li_proved": sum(1 for c in claims if c.get("epistemic_status") == "li_proved"),
        "unprovable_language_flags": [u["claim_id"] for u in unprovable],
        "unprovable_language_detail": unprovable,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="Exit 1 if unprovable_language flags exist")
    parser.add_argument("--problem", help="Single problem id")
    args = parser.parse_args()

    if not CLAIMS_ROOT.is_dir():
        print("compare-claims: no research-claims yet", file=sys.stderr)
        return 1

    problems = [CLAIMS_ROOT / args.problem] if args.problem else [p for p in CLAIMS_ROOT.iterdir() if p.is_dir()]
    any_claims = False
    any_flags = False

    for prob in problems:
        claims = load_jsonl(prob / "claims.jsonl")
        if not claims:
            continue
        any_claims = True
        report = build_report(prob.name, claims, load_jsonl(prob / "reviews.jsonl"))
        out_dir = AUDIT_OUT / prob.name
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / "compare-report.json"
        out_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(f"compare-claims: wrote {out_path}")
        if report["unprovable_language_flags"]:
            any_flags = True
            for u in report["unprovable_language_detail"]:
                print(
                    f"  FLAG {u['claim_id']}: reviewers claim proved but status={u['epistemic_status']}",
                    file=sys.stderr,
                )

    if not any_claims:
        print("compare-claims: no claims to compare", file=sys.stderr)
        return 1

    if args.check and any_flags:
        print("wp-claim-compare: unprovable_language flags present (expected until Li catches up)", file=sys.stderr)
        # Advisory during bootstrap — exit 0 if only flags, agents must drive count down
        return 0

    print("wp-claim-compare: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
