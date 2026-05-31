#!/usr/bin/env python3
"""Export research audit bundle for static claim audit UI (Phase 3 WP-AU)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CLAIMS_ROOT = ROOT / "proof-db" / "research-claims"
UI_DATA = ROOT / "deploy" / "research-audit" / "data"


def load_jsonl(path: Path) -> list[dict]:
    if not path.is_file():
        return []
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def main() -> int:
    if not CLAIMS_ROOT.is_dir():
        print("export-audit-ui: no claims", file=sys.stderr)
        return 1

    exported = 0
    for prob in sorted(p for p in CLAIMS_ROOT.iterdir() if p.is_dir()):
        claims = load_jsonl(prob / "claims.jsonl")
        if not claims:
            continue
        reviews = load_jsonl(prob / "reviews.jsonl")
        compare_path = ROOT / "data" / "research-audit" / prob.name / "compare-report.json"
        compare = json.loads(compare_path.read_text(encoding="utf-8")) if compare_path.is_file() else {}

        by_claim: dict[str, list] = {}
        for r in reviews:
            by_claim.setdefault(r.get("claim_id", ""), []).append(r)

        bundle = {
            "problem_id": prob.name,
            "claims": claims,
            "reviews_by_claim": by_claim,
            "compare_report": compare,
        }
        out = UI_DATA / f"{prob.name}.json"
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(bundle, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"export-audit-ui: wrote {out}")
        exported += 1

    if exported < 1:
        print("export-audit-ui: nothing exported", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
