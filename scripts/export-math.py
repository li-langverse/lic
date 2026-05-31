#!/usr/bin/env python3
"""Export proof-database math-field catalog rows as JSON (Proof Explorer WP3).

Used by `lic export-math` and proof-library ingest. Emits schema v3 rich fields
(latex, context, sources, content_tier) when present.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import tomllib
except ImportError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

ROOT = Path(os.environ.get("LI_REPO_ROOT", Path(__file__).resolve().parents[1])).resolve()
ENTRIES = ROOT / "docs/verification/proof-database/entries"
SCHEMA_PATH = ROOT / "docs/verification/proof-database/schema.toml"
ATTRIBUTION_PATH = ROOT / "proof-db/attribution.toml"

EXPORT_KEYS = (
    "id",
    "kind",
    "field",
    "domain",
    "statement",
    "proof_status",
    "erdos_id",
    "erdos_number",
    "erdos_status",
    "priority_tier",
    "gap_id",
    "gap_kind",
    "lean_module",
    "lean_thm",
    "register_source",
    "external_url",
    "content_tier",
    "latex",
    "context",
    "sources",
    "notes",
    "li_specimen",
    "last_verified_lic_commit",
)


def load_attribution() -> dict:
    if not ATTRIBUTION_PATH.is_file():
        return {}
    data = tomllib.loads(ATTRIBUTION_PATH.read_text(encoding="utf-8"))
    out: dict = {}
    for section in ("project", "curator", "footer"):
        block = data.get(section)
        if isinstance(block, dict):
            out[section] = block
    return out


def parse_entries(path: Path) -> list[dict]:
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    raw = data.get("entry")
    if raw is None:
        return []
    if isinstance(raw, dict):
        return [raw]
    return [e for e in raw if isinstance(e, dict)]


def slim_entry(entry: dict, source_toml: str) -> dict:
    row = {k: entry[k] for k in EXPORT_KEYS if k in entry}
    row["_source_toml"] = source_toml
    return row


def collect_math_entries() -> list[dict]:
    rows: list[dict] = []
    if not ENTRIES.is_dir():
        return rows
    for path in sorted(ENTRIES.glob("*.toml")):
        for entry in parse_entries(path):
            field = str(entry.get("field", "")).lower()
            eid = str(entry.get("id", ""))
            if field != "math" and not eid.startswith(("M-AX-", "M-LM-", "M-CONJ-")):
                continue
            if not entry.get("id"):
                continue
            rows.append(slim_entry(entry, str(path.relative_to(ROOT))))
    rows.sort(key=lambda r: str(r.get("id", "")))
    return rows


def build_payload(entries: list[dict]) -> dict:
    schema_version = 3
    if SCHEMA_PATH.is_file():
        schema = tomllib.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
        ver = schema.get("schema", {}).get("version")
        if isinstance(ver, int):
            schema_version = ver
    return {
        "schema_version": schema_version,
        "exported_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "field": "math",
        "entry_count": len(entries),
        "attribution": load_attribution(),
        "entries": entries,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Export math-field proof-database catalog rows")
    parser.add_argument(
        "-o",
        "--out",
        help="Write JSON to PATH (default: stdout)",
    )
    parser.add_argument(
        "--pretty",
        action="store_true",
        help="Pretty-print JSON",
    )
    args = parser.parse_args()

    entries = collect_math_entries()
    if not entries:
        print("export-math: no math-field entries found", file=sys.stderr)
        sys.exit(1)

    payload = build_payload(entries)
    text = json.dumps(payload, indent=2 if args.pretty else None, sort_keys=args.pretty)
    text += "\n"

    if args.out:
        out_path = Path(args.out)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(text, encoding="utf-8")
        print(f"export-math: wrote {len(entries)} entries → {out_path}", file=sys.stderr)
    else:
        sys.stdout.write(text)


if __name__ == "__main__":
    main()
