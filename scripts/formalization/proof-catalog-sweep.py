#!/usr/bin/env python3
"""One-pass proof corpus sweep — catalog entries + proof-db/**/*.li specimens.

Appends JSONL rows to data/proof-explorer-loop/proof-sweep-log.jsonl:
  {id, path, proof_status, sweep_status, note, source?}

sweep_status: reviewed | skipped | stub | discharged
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import tomllib
except ImportError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

ROOT = Path(__file__).resolve().parents[2]
ENTRIES = ROOT / "docs/verification/proof-database/entries"
LOG_PATH = ROOT / "data/proof-explorer-loop/proof-sweep-log.jsonl"
DISCHARGE_LOG = ROOT / "data/proof-explorer-loop/discharge-log.jsonl"

STUB_MARKERS = re.compile(
    r"(#+\s*TODO|#+\s*stub|unimplemented|not\s+yet\s+proved|placeholder)",
    re.IGNORECASE,
)
DISCHARGE_MARKERS = re.compile(
    r"(lic verify:\s*passed|# discharge:\s*ok|# discharge:ok)",
    re.IGNORECASE,
)


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


def specimen_path(entry: dict) -> Path | None:
    raw = (entry.get("li_specimen") or "").strip()
    if raw:
        p = ROOT / raw
        return p if p.is_file() else None
    eid = str(entry.get("id", ""))
    if eid.startswith("E-"):
        p = ROOT / "proof-db" / "erdos" / "specimens" / f"{eid}.li"
        return p if p.is_file() else None
    if eid.startswith("M-CONJ-"):
        p = ROOT / "proof-db" / "math" / "specimens" / f"{eid}.li"
        return p if p.is_file() else None
    field = str(entry.get("field", ""))
    if field:
        p = ROOT / "proof-db" / field / "specimens" / f"{eid}.li"
        if p.is_file():
            return p
    return None


def discharged_ids() -> set[str]:
    out: set[str] = set()
    if not DISCHARGE_LOG.is_file():
        return out
    for line in DISCHARGE_LOG.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        eid = str(row.get("entry_id") or row.get("id") or "").strip()
        if eid:
            out.add(eid)
    return out


def classify_entry(entry: dict, spec: Path | None, discharged: set[str]) -> tuple[str, str]:
    eid = str(entry.get("id", ""))
    status = str(entry.get("proof_status", ""))
    kind = str(entry.get("kind", ""))

    if eid in discharged:
        return "discharged", "listed in discharge-log.jsonl"

    if status == "axiomatic":
        lean = (entry.get("lean_module") or "").strip()
        if lean and (ROOT / lean.split("#", 1)[0]).is_file():
            return "skipped", "axiomatic with lean_module"
        return "skipped", "axiomatic (no specimen sweep required)"

    if spec and spec.is_file():
        text = spec.read_text(encoding="utf-8", errors="replace")
        if DISCHARGE_MARKERS.search(text):
            return "discharged", "specimen discharge marker"
        if status == "proved" and (entry.get("lean_thm") or "").strip():
            return "discharged", "proved+lean_thm"
        if STUB_MARKERS.search(text) or len(text.strip()) < 80:
            return "stub", "stub/TODO specimen body"
        if status in ("proved", "partial", "open"):
            return "reviewed", f"specimen present; proof_status={status}"
        return "reviewed", "specimen present"

    if status in ("proved", "partial"):
        return "reviewed", f"no specimen file; proof_status={status}"

    if kind == "conjecture" or status == "open":
        return "reviewed", "open/conjecture — logged, no verify required"

    return "reviewed", f"catalog-only; proof_status={status or 'unknown'}"


def classify_specimen_file(path: Path) -> tuple[str, str]:
    rel = path.relative_to(ROOT).as_posix()
    eid = path.stem
    text = path.read_text(encoding="utf-8", errors="replace")
    if DISCHARGE_MARKERS.search(text):
        return "discharged", rel
    if STUB_MARKERS.search(text) or len(text.strip()) < 80:
        return "stub", rel
    return "reviewed", rel


def load_existing_keys(full: bool) -> tuple[set[str], set[str]]:
    if full or not LOG_PATH.is_file():
        return set(), set()
    catalog_ids: set[str] = set()
    specimen_paths: set[str] = set()
    for line in LOG_PATH.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        src = str(row.get("source", ""))
        rid = str(row.get("id", ""))
        rpath = str(row.get("path", ""))
        if src == "catalog" and rid:
            catalog_ids.add(rid)
        elif src == "specimen" and rpath:
            specimen_paths.add(rpath)
    return catalog_ids, specimen_paths


def write_rows(rows: list[dict], append: bool) -> None:
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    mode = "w" if not append else "a"
    with LOG_PATH.open(mode, encoding="utf-8") as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")


def sweep(*, full: bool, dry_run: bool) -> dict:
    ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    discharged = discharged_ids()
    seen_catalog, seen_specimens = load_existing_keys(full)
    out: list[dict] = []

    for entry in parse_all_entries():
        eid = str(entry.get("id", ""))
        if not eid:
            continue
        if not full and eid in seen_catalog:
            continue
        spec = specimen_path(entry)
        rel_path = spec.relative_to(ROOT).as_posix() if spec else ""
        sweep_status, note = classify_entry(entry, spec, discharged)
        out.append(
            {
                "id": eid,
                "path": rel_path,
                "proof_status": str(entry.get("proof_status", "")),
                "sweep_status": sweep_status,
                "note": note,
                "source": "catalog",
                "swept_at": ts,
            }
        )

    catalog_paths = {specimen_path(e) for e in parse_all_entries()}
    catalog_paths.discard(None)

    for path in sorted((ROOT / "proof-db").rglob("*.li")):
        rel = path.relative_to(ROOT).as_posix()
        if path in catalog_paths:
            continue
        if not full and rel in seen_specimens:
            continue
        sweep_status, note = classify_specimen_file(path)
        out.append(
            {
                "id": f"@{path.stem}",
                "path": rel,
                "proof_status": "",
                "sweep_status": sweep_status,
                "note": note,
                "source": "specimen",
                "swept_at": ts,
            }
        )

    if not dry_run:
        write_rows(out, append=not full)

    # Summary counts from full log
    catalog_swept: set[str] = set()
    if LOG_PATH.is_file():
        for line in LOG_PATH.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                continue
            if row.get("source") == "catalog" and row.get("id"):
                catalog_swept.add(str(row["id"]))

    return {
        "appended": len(out),
        "catalog_total": len(parse_all_entries()),
        "catalog_in_log": len(catalog_swept),
        "log_path": str(LOG_PATH.relative_to(ROOT)),
        "dry_run": dry_run,
        "full": full,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--full", action="store_true", help="Rewrite sweep log (one complete pass)")
    ap.add_argument("--dry-run", action="store_true", help="Print summary only")
    args = ap.parse_args()

    summary = sweep(full=args.full, dry_run=args.dry_run)
    print(
        f"proof-catalog-sweep: appended={summary['appended']} "
        f"catalog_in_log={summary['catalog_in_log']}/{summary['catalog_total']} "
        f"log={summary['log_path']}"
    )
    if summary["catalog_in_log"] < summary["catalog_total"] and not args.dry_run:
        print(
            f"  (run with --full to resweep all {summary['catalog_total']} catalog ids)",
            file=sys.stderr,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
