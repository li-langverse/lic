#!/usr/bin/env python3
"""Generate open Li specimen stubs and patch catalog rows for formalization coverage."""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

ROOT = Path(__file__).resolve().parents[2]
ENTRIES = ROOT / "docs/verification/proof-database/entries"
ERDOS_SPEC = ROOT / "proof-db" / "erdos" / "specimens"
MATH_SPEC = ROOT / "proof-db" / "math" / "specimens"
FIELD_SPEC_ROOTS = {
    "biology": ROOT / "proof-db" / "biology" / "specimens",
    "chemistry": ROOT / "proof-db" / "chemistry" / "specimens",
    "graph": ROOT / "proof-db" / "graph" / "specimens",
    "ml": ROOT / "proof-db" / "ml" / "specimens",
    "physics": ROOT / "proof-db" / "physics" / "specimens",
    "statistics": ROOT / "proof-db" / "statistics" / "specimens",
    "linalg": ROOT / "proof-db" / "linalg" / "specimens",
}


def slug_id(entry_id: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]", "_", entry_id)


def stub_body(entry_id: str, statement: str, erdos_status: str | None = None) -> str:
    stmt = " ".join(statement.split())[:240]
    lines = [
        f"# Catalog: {entry_id}",
        f"# Statement: {stmt}",
        "# formalization_status: li_open",
        "# discharge: pending — open formalization target (Phase 4)",
    ]
    if erdos_status:
        lines.append(f"# erdos_status (literature): {erdos_status}")
    fn = slug_id(entry_id).lower()
    lines.extend(
        [
            "",
            f"def formal_target_{fn}() -> int",
            "  requires true",
            "  ensures result == 0",
            "  decreases 0",
            "=",
            "  return 0",
            "",
        ]
    )
    return "\n".join(lines)


def parse_entries() -> list[dict]:
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
                rows.append(entry)
    return rows


def tranche(entry: dict) -> str | None:
    eid = str(entry.get("id", ""))
    if eid.startswith("M-CONJ-"):
        return "T1"
    if eid.startswith("E-") and entry.get("priority_tier") == "P0":
        return "T2"
    if eid.startswith("E-") and entry.get("erdos_status") == "proved":
        return "T3"
    if eid.startswith("E-"):
        return "T4"
    field = str(entry.get("field", ""))
    if field in FIELD_SPEC_ROOTS:
        return "OTHER"
    return None


def specimen_dir(entry: dict) -> Path | None:
    eid = str(entry.get("id", ""))
    if eid.startswith("E-"):
        return ERDOS_SPEC
    if eid.startswith("M-CONJ-"):
        return MATH_SPEC
    field = str(entry.get("field", ""))
    return FIELD_SPEC_ROOTS.get(field)


def write_stub(entry: dict) -> Path | None:
    eid = str(entry.get("id", ""))
    statement = str(entry.get("statement", eid))
    erdos_status = entry.get("erdos_status")

    if eid.startswith("E-"):
        path = ERDOS_SPEC / f"{eid}.li"
    elif eid.startswith("M-CONJ-"):
        path = MATH_SPEC / f"{eid}.li"
    else:
        base = specimen_dir(entry)
        if not base:
            return None
        path = base / f"{eid}.li"

    if path.is_file():
        return path

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(stub_body(eid, statement, str(erdos_status) if erdos_status else None), encoding="utf-8")
    return path


def patch_math_conjectures(stubs: dict[str, str]) -> int:
    path = ENTRIES / "math-conjectures.toml"
    if not path.is_file() or not stubs:
        return 0
    text = path.read_text(encoding="utf-8")
    changed = 0
    for eid, rel in stubs.items():
        if f'id = "{eid}"' not in text:
            continue
        if f'li_specimen = "{rel}"' in text:
            continue
        # Insert li_specimen after proof_status line within entry block
        pattern = rf'(id = "{re.escape(eid)}"[\s\S]*?proof_status = "[^"]+")\n'
        repl = rf'\1\nli_specimen = "{rel}"\n'
        new_text, n = re.subn(pattern, repl, text, count=1)
        if n:
            text = new_text
            changed += 1
    if changed:
        path.write_text(text, encoding="utf-8")
    return changed


def patch_erdos_sync() -> None:
    sync = ROOT / "proof-db" / "erdos" / "scripts" / "erdos_sync_catalog.py"
    subprocess.run([sys.executable, str(sync)], cwd=ROOT, check=True)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--tranche",
        choices=["T1", "T2", "T3", "T4", "T2T3", "all-erdos", "OTHER", "all"],
        default="T1",
        help="Which catalog rows to bootstrap",
    )
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    selected = {
        "T1": {"T1"},
        "T2": {"T2"},
        "T3": {"T3"},
        "T4": {"T4"},
        "T2T3": {"T2", "T3"},
        "all-erdos": {"T2", "T3", "T4"},
        "OTHER": {"OTHER"},
        "all": {"T1", "T2", "T3", "T4", "OTHER"},
    }[args.tranche]

    created = 0
    mconj_stubs: dict[str, str] = {}

    for entry in parse_entries():
        t = tranche(entry)
        if t not in selected:
            continue
        eid = str(entry.get("id", ""))
        if args.dry_run:
            print("would stub", eid)
            continue
        path = write_stub(entry)
        if path:
            created += 1
            if eid.startswith("M-CONJ-"):
                rel = path.relative_to(ROOT).as_posix()
                mconj_stubs[eid] = rel

    if args.dry_run:
        return 0

    patch_math_conjectures(mconj_stubs)

    if selected & {"T2", "T3", "T4"}:
        # Update erdos_sync_catalog.py output to include li_specimen paths
        patch_erdos_sync()

    print(f"bootstrap-specimen-stubs: created {created} stub(s) for tranche {args.tranche}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
