#!/usr/bin/env python3
"""Audit Li formalization coverage for proof-database catalog entries."""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path

try:
    import tomllib
except ImportError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

ROOT = Path(__file__).resolve().parents[2]
ENTRIES = ROOT / "docs/verification/proof-database/entries"


@dataclass
class RowResult:
    entry_id: str
    field: str
    proof_status: str
    tranche: str
    covered: bool
    reason: str
    li_specimen: str | None = None


def parse_all_entries() -> list[dict]:
    rows: list[dict] = []
    for path in sorted(ENTRIES.glob("*.toml")):
        if path.name == "schema.toml":
            continue
        data = tomllib.loads(path.read_text(encoding="utf-8"))
        batch = data.get("entry") or []
        if isinstance(batch, dict):
            batch = [batch]
        for entry in batch:
            if isinstance(entry, dict):
                entry = dict(entry)
                entry["_catalog"] = path.name
                rows.append(entry)
    return rows


def tranche_for(entry: dict) -> str:
    eid = str(entry.get("id", ""))
    if eid.startswith("M-AX-") or eid.startswith("M-LM-"):
        return "T0"
    if eid.startswith("M-CONJ-"):
        return "T1"
    if eid.startswith("E-") and entry.get("priority_tier") == "P0":
        return "T2"
    if eid.startswith("E-") and entry.get("erdos_status") == "proved":
        return "T3"
    if eid.startswith("E-"):
        return "T4"
    return "OTHER"


def specimen_path(entry: dict) -> Path | None:
    raw = (entry.get("li_specimen") or "").strip()
    if raw:
        return ROOT / raw
    eid = str(entry.get("id", ""))
    if eid.startswith("E-"):
        return ROOT / "proof-db" / "erdos" / "specimens" / f"{eid}.li"
    if eid.startswith("M-CONJ-"):
        return ROOT / "proof-db" / "math" / "specimens" / f"{eid}.li"
    field = str(entry.get("field", ""))
    if field:
        p = ROOT / "proof-db" / field / "specimens" / f"{eid}.li"
        if p.is_file():
            return p
    return None


def is_covered(entry: dict) -> tuple[bool, str]:
    status = str(entry.get("proof_status", ""))
    kind = str(entry.get("kind", ""))
    eid = str(entry.get("id", ""))

    if status == "axiomatic":
        lean = (entry.get("lean_module") or "").strip()
        if lean and (ROOT / lean.split("#", 1)[0]).is_file():
            return True, "axiomatic+lean_module"
        return False, "axiomatic missing lean_module file"

    spec = specimen_path(entry)
    if spec and spec.is_file():
        if status == "proved":
            lean_thm = (entry.get("lean_thm") or "").strip()
            if lean_thm:
                return True, "proved+lean_thm"
            text = spec.read_text(encoding="utf-8", errors="replace")
            if "lic verify: passed" in text or "# discharge: ok" in text:
                return True, "proved+specimen discharge marker"
            return False, "proved without Li discharge (need target or verify)"
        return True, "li_specimen stub"

    if status in ("open", "target") and (entry.get("gap_id") or "").strip():
        return False, "gap_id only — need li_specimen file"

    return False, "no li_specimen"


def audit(entries: list[dict]) -> list[RowResult]:
    out: list[RowResult] = []
    for entry in entries:
        eid = str(entry.get("id", "?"))
        covered, reason = is_covered(entry)
        spec = specimen_path(entry)
        out.append(
            RowResult(
                entry_id=eid,
                field=str(entry.get("field", "")),
                proof_status=str(entry.get("proof_status", "")),
                tranche=tranche_for(entry),
                covered=covered,
                reason=reason,
                li_specimen=str(spec.relative_to(ROOT)).replace("\\", "/") if spec else None,
            )
        )
    return out


def summarize(results: list[RowResult]) -> dict:
    def pct(tranche: str) -> float:
        rows = [r for r in results if r.tranche == tranche]
        if not rows:
            return 100.0
        return 100.0 * sum(1 for r in rows if r.covered) / len(rows)

    return {
        "total": len(results),
        "covered": sum(1 for r in results if r.covered),
        "pct_overall": 100.0 * sum(1 for r in results if r.covered) / max(1, len(results)),
        "T0_pct": pct("T0"),
        "T1_pct": pct("T1"),
        "T2_pct": pct("T2"),
        "T3_pct": pct("T3"),
        "T4_pct": pct("T4"),
        "uncovered_sample": [asdict(r) for r in results if not r.covered][:20],
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--json-out", type=Path, help="Write JSON report")
    ap.add_argument("--min-t0", type=float, default=100.0)
    ap.add_argument("--min-t1", type=float, default=100.0)
    ap.add_argument("--min-t2", type=float, default=100.0)
    ap.add_argument("--min-overall", type=float, default=0.0)
    args = ap.parse_args()

    results = audit(parse_all_entries())
    summary = summarize(results)

    print(f"li-coverage: {summary['covered']}/{summary['total']} ({summary['pct_overall']:.1f}%)")
    for key in ("T0_pct", "T1_pct", "T2_pct", "T3_pct", "T4_pct"):
        print(f"  {key}: {summary[key]:.1f}%")

    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps({"summary": summary, "results": [asdict(r) for r in results]}, indent=2), encoding="utf-8")

    fail = 0
    if summary["T0_pct"] < args.min_t0:
        print(f"FAIL: T0 {summary['T0_pct']:.1f}% < {args.min_t0}%", file=sys.stderr)
        fail = 1
    if summary["T1_pct"] < args.min_t1:
        print(f"FAIL: T1 {summary['T1_pct']:.1f}% < {args.min_t1}%", file=sys.stderr)
        fail = 1
    if summary["T2_pct"] < args.min_t2:
        print(f"FAIL: T2 {summary['T2_pct']:.1f}% < {args.min_t2}%", file=sys.stderr)
        fail = 1
    if summary["pct_overall"] < args.min_overall:
        print(f"FAIL: overall {summary['pct_overall']:.1f}% < {args.min_overall}%", file=sys.stderr)
        fail = 1

    if fail:
        print("check-li-coverage: INCOMPLETE", file=sys.stderr)
        return 1
    print("check-li-coverage: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
