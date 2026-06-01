#!/usr/bin/env python3
"""Append a research claim or review row to JSONL ledger (Phase 3 WP-CL)."""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CLAIMS_ROOT = ROOT / "proof-db" / "research-claims"
SCHEMA = CLAIMS_ROOT / "schema.toml"


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def validate_row(row: dict, kind: str) -> None:
    required_claim = {
        "claim_id",
        "problem_id",
        "statement_plain",
        "author_agent",
        "created_at",
        "epistemic_status",
    }
    required_review = {"claim_id", "reviewer_model", "verdict", "reviewed_at"}
    req = required_claim if kind == "claim" else required_review
    missing = req - set(row.keys())
    if missing:
        raise SystemExit(f"append-claim: missing required fields: {sorted(missing)}")


def append_jsonl(path: Path, row: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(row, ensure_ascii=False) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description="Append claim or review to research ledger")
    parser.add_argument("--problem", required=True, help="Problem id directory (e.g. E-52)")
    parser.add_argument("--kind", choices=["claim", "review"], default="claim")
    parser.add_argument("--json", help="Inline JSON object")
    parser.add_argument("--json-file", help="Path to JSON object file")
    parser.add_argument("--set-created-at", action="store_true", help="Stamp created_at/reviewed_at if absent")
    args = parser.parse_args()

    if not SCHEMA.is_file():
        print("append-claim: schema.toml missing", file=sys.stderr)
        return 1

    if args.json_file:
        row = json.loads(Path(args.json_file).read_text(encoding="utf-8"))
    elif args.json:
        row = json.loads(args.json)
    else:
        print("append-claim: provide --json or --json-file", file=sys.stderr)
        return 1

    if args.set_created_at:
        ts_key = "created_at" if args.kind == "claim" else "reviewed_at"
        row.setdefault(ts_key, now_iso())

    validate_row(row, args.kind)
    fname = "claims.jsonl" if args.kind == "claim" else "reviews.jsonl"
    path = CLAIMS_ROOT / args.problem / fname
    append_jsonl(path, row)
    print(f"append-claim: appended to {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
