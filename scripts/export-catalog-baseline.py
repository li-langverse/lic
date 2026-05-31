#!/usr/bin/env python3
"""Export catalog specimen hash baseline for Phase 5 WP-DS-03 (BUG-C-06/07)."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

ROOT = Path(__file__).resolve().parents[1]
ENTRIES = ROOT / "docs/verification/proof-database/entries"
SCHEMA = ROOT / "docs/verification/proof-database/schema.toml"


def parse_entries(path: Path) -> list[dict]:
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    raw = data.get("entry")
    if raw is None:
        return []
    if isinstance(raw, dict):
        return [raw]
    return [e for e in raw if isinstance(e, dict)]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


def main() -> None:
    rows: list[dict] = []
    for path in sorted(ENTRIES.glob("*.toml")):
        for entry in parse_entries(path):
            eid = entry.get("id", "?")
            specimen = (entry.get("li_specimen") or "").strip()
            row = {
                "id": eid,
                "proof_status": entry.get("proof_status"),
                "gap_kind": entry.get("gap_kind"),
                "li_specimen": specimen or None,
                "source": path.name,
            }
            if specimen:
                spec_path = ROOT / specimen
                if spec_path.is_file():
                    row["specimen_sha256"] = sha256_file(spec_path)
                else:
                    row["specimen_missing"] = True
            rows.append(row)

    out = ROOT / "proof-db/catalog-baseline.jsonl"
    with out.open("w", encoding="utf-8") as f:
        for row in sorted(rows, key=lambda r: str(r["id"])):
            f.write(json.dumps(row, sort_keys=True) + "\n")
    print(f"export-catalog-baseline: wrote {len(rows)} rows to {out.relative_to(ROOT)}", file=sys.stderr)


if __name__ == "__main__":
    main()
