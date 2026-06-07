#!/usr/bin/env python3
"""Remove pre-phase8 catalog rows superseded by phase-8 basic-corpus canonical IDs."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENTRIES = ROOT / "docs/verification/proof-database/entries"

# Prior entry id -> BC canonical id (BC row kept; prior row removed).
SUPERSEDED: dict[str, str] = {
    "ST-AX-PROB-FINITE": "ST-AX-BC-PR-001",
    "ST-AX-EXPECT-LINEAR": "ST-AX-BC-EX-002",
    "GT-AX-SIMPLE-GRAPH": "GT-AX-BC-GR-005",
    "GT-LM-HANDSHAKING": "GT-LM-BC-HS-001",
    "P-AX-MECH-001": "P-AX-BC-MEC-001",
    "P-AX-MECH-002": "P-AX-BC-MEC-002",
    "P-AX-MECH-003": "P-AX-BC-MEC-003",
}


def remove_entry_blocks(text: str, drop_ids: set[str]) -> tuple[str, list[str]]:
    removed: list[str] = []
    parts = re.split(r"(?=\[\[entry\]\])", text)
    kept: list[str] = [parts[0]]
    for part in parts[1:]:
        m = re.search(r'^id\s*=\s*"([^"]+)"', part, re.M)
        if m and m.group(1) in drop_ids:
            removed.append(m.group(1))
            continue
        kept.append(part)
    return "".join(kept), removed


def bc_ids_present() -> set[str]:
    note = "phase8-basic-corpus"
    found: set[str] = set()
    for path in ENTRIES.glob("*-basic-corpus.toml"):
        text = path.read_text(encoding="utf-8")
        if note not in text:
            continue
        for m in re.finditer(r'^id\s*=\s*"([^"]+)"', text, re.M):
            found.add(m.group(1))
    return found


def main() -> int:
    bc = bc_ids_present()
    to_drop: set[str] = set()
    for prior, canonical in SUPERSEDED.items():
        if canonical in bc:
            to_drop.add(prior)
        else:
            print(f"skip {prior}: BC canonical {canonical} not ingested yet", file=sys.stderr)

    if not to_drop:
        print("dedupe: nothing to remove")
        return 0

    total_removed: list[str] = []
    for path in sorted(ENTRIES.glob("*.toml")):
        if path.name.endswith("-basic-corpus.toml"):
            continue
        text = path.read_text(encoding="utf-8")
        new_text, removed = remove_entry_blocks(text, to_drop)
        if removed:
            path.write_text(new_text, encoding="utf-8")
            total_removed.extend(removed)
            print(f"  {path.name}: removed {', '.join(removed)}")

    print(f"dedupe: removed {len(total_removed)} superseded entries")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
