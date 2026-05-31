#!/usr/bin/env python3
"""Merge proof-db/erdos/overlays.json patches into register.json (WP6).

Never overwrites rows with content_tier=polished. Skips unknown problem numbers.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[3]
REGISTER = ROOT / "proof-db" / "erdos" / "register.json"
OVERLAYS = ROOT / "proof-db" / "erdos" / "overlays.json"

PATCH_KEYS = (
    "content_tier",
    "latex",
    "context",
    "sources",
    "notes",
    "statement",
    "tags",
)


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_register(path: Path, data: dict[str, Any]) -> None:
    data["problems"] = sorted(data["problems"], key=lambda r: int(r["number"]))
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def merge_patch(row: dict[str, Any], patch: dict[str, Any]) -> bool:
    if row.get("content_tier") == "polished":
        return False
    changed = False
    for key in PATCH_KEYS:
        if key not in patch:
            continue
        if row.get(key) != patch[key]:
            row[key] = patch[key]
            changed = True
    return changed


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--register", type=Path, default=REGISTER)
    ap.add_argument("--overlays", type=Path, default=OVERLAYS)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    reg = load_json(args.register)
    ov = load_json(args.overlays)
    overlays = ov.get("overlays") or []
    if not isinstance(overlays, list):
        raise SystemExit(f"{args.overlays}: overlays must be a list")

    by_num = {int(r["number"]): r for r in reg.get("problems", [])}
    applied = skipped_polished = missing = 0

    for entry in overlays:
        num = int(entry["number"])
        patch = entry.get("patch") or {k: entry[k] for k in PATCH_KEYS if k in entry}
        if num not in by_num:
            missing += 1
            continue
        row = by_num[num]
        if row.get("content_tier") == "polished":
            skipped_polished += 1
            continue
        if merge_patch(row, patch):
            applied += 1

    print(
        f"overlays: {len(overlays)} rows; applied {applied}; "
        f"skipped polished {skipped_polished}; missing {missing}"
    )
    if args.dry_run:
        return 0
    save_register(args.register, reg)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
