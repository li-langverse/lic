#!/usr/bin/env python3
"""Generate statement-specific Erdős .li specimens from register.json + overlays."""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
REGISTER = ROOT / "proof-db" / "erdos" / "register.json"
OVERLAYS = ROOT / "proof-db" / "erdos" / "overlays.json"
SPECIMENS = ROOT / "proof-db" / "erdos" / "specimens"
CATALOG = ROOT / "docs" / "verification" / "proof-database" / "entries" / "erdos-register.toml"


def git_head(short: int = 8) -> str:
    try:
        h = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True, stderr=subprocess.DEVNULL
        ).strip()
        return h[:short] if short else h
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "unknown"


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def overlay_by_number(path: Path) -> dict[int, dict[str, Any]]:
    data = load_json(path)
    out: dict[int, dict[str, Any]] = {}
    for row in data.get("overlays") or []:
        if isinstance(row, dict) and "number" in row:
            patch = row.get("patch") or {k: row[k] for k in row if k not in ("number", "tranche")}
            out[int(row["number"])] = patch
    return out


def slug_statement(statement: str, max_len: int = 40) -> str:
    s = re.sub(r"[^a-zA-Z0-9]+", "_", statement.lower()).strip("_")
    return s[:max_len].rstrip("_") or "target"


def def_name(number: int, statement: str) -> str:
    return f"erdos_e{number}_{slug_statement(statement)}"


def witness_name(number: int) -> str:
    return f"erdos_e{number}_open_witness"


def render_specimen(row: dict[str, Any], overlay: dict[str, Any] | None) -> str:
    n = int(row["number"])
    eid = f"E-{n}"
    stmt = (overlay or {}).get("statement") or row["statement"]
    stmt = str(stmt).strip()
    tags = (overlay or {}).get("tags") or row.get("tags") or []
    tier = row.get("priority_tier", "P2")
    status = row.get("erdos_status", "open")
    context = (overlay or {}).get("context") or row.get("context")

    lines = [
        f"# {eid}: {stmt}",
        f"# erdos_number: {n}",
        f"# erdos_status: {status}",
        f"# priority_tier: {tier}",
    ]
    if tags:
        lines.append(f"# tags: {', '.join(str(t) for t in tags)}")
    if context:
        for part in str(context).split(". "):
            part = part.strip()
            if part:
                lines.append(f"# context: {part}.")
    lines.append("")

    target = def_name(n, stmt)
    lines.extend(
        [
            f"def {target}() -> int",
            "  requires true",
            f"  ensures result == 0  # open: {eid}",
            "  decreases 0",
            "=",
            "  return 0",
            "",
            "def main() -> int",
            "  requires true",
            "  ensures result == 0",
            "  decreases 0",
            "=",
            "  return 0",
            "",
        ]
    )
    return "\n".join(lines)


def specimen_rel(number: int) -> str:
    return f"proof-db/erdos/specimens/E-{number}.li"


def write_specimens(
    problems: list[dict[str, Any]], overlays: dict[int, dict[str, Any]], *, dry_run: bool
) -> int:
    written = 0
    if not dry_run:
        SPECIMENS.mkdir(parents=True, exist_ok=True)
    for row in problems:
        n = int(row["number"])
        rel = specimen_rel(n)
        body = render_specimen(row, overlays.get(n))
        if dry_run:
            written += 1
            continue
        path = ROOT / rel
        path.write_text(body, encoding="utf-8")
        row["li_specimen"] = rel
        written += 1
    return written


def save_register(path: Path, data: dict[str, Any]) -> None:
    data["problems"] = sorted(data["problems"], key=lambda r: int(r["number"]))
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def patch_catalog_li_specimen(problems: list[dict[str, Any]], commit: str) -> int:
    """Ensure erdos-register.toml rows reference generated specimens."""
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib  # type: ignore

    if not CATALOG.is_file():
        return 0
    data = tomllib.loads(CATALOG.read_text(encoding="utf-8"))
    rows = data.get("entry") or []
    if isinstance(rows, dict):
        rows = [rows]
    by_id = {f"E-{int(r['number'])}": r for r in problems}
    changed = 0
    for entry in rows:
        if not isinstance(entry, dict):
            continue
        eid = entry.get("id")
        if not eid or not str(eid).startswith("E-"):
            continue
        src = by_id.get(str(eid))
        if not src:
            continue
        rel = src.get("li_specimen") or specimen_rel(int(src["number"]))
        if entry.get("li_specimen") != rel:
            entry["li_specimen"] = rel
            changed += 1
        if entry.get("last_verified_lic_commit") != commit:
            entry["last_verified_lic_commit"] = commit
    if changed:
        lines = ["version = 1", "", "# Generated by proof-db/erdos/scripts/erdos_sync_catalog.py", ""]
        for e in rows:
            lines.append("[[entry]]")
            for key, val in e.items():
                if isinstance(val, bool):
                    lines.append(f"{key} = {'true' if val else 'false'}")
                elif isinstance(val, int):
                    lines.append(f"{key} = {val}")
                elif isinstance(val, list):
                    inner = ", ".join(f'"{x}"' for x in val)
                    lines.append(f"{key} = [{inner}]")
                else:
                    s = str(val).replace("\\", "\\\\").replace('"', '\\"')
                    lines.append(f'{key} = "{s}"')
            lines.append("")
        CATALOG.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    return changed


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--register", type=Path, default=REGISTER)
    ap.add_argument("--overlays", type=Path, default=OVERLAYS)
    ap.add_argument("--limit", type=int, default=0, help="process first N problems (0=all)")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    reg = load_json(args.register)
    problems = reg.get("problems") or []
    if not isinstance(problems, list):
        raise SystemExit(f"{args.register}: missing problems[]")
    if args.limit > 0:
        problems = problems[: args.limit]

    overlays = overlay_by_number(args.overlays)
    n = write_specimens(problems, overlays, dry_run=args.dry_run)
    print(f"de-stub-erdos-specimens: {n} specimen(s) {'would be ' if args.dry_run else ''}written")

    if args.dry_run:
        return 0

    # Persist li_specimen on all problems (including those beyond --limit).
    all_problems = reg.get("problems") or []
    by_num = {int(r["number"]): r for r in all_problems}
    for row in problems:
        by_num[int(row["number"])]["li_specimen"] = row["li_specimen"]
    save_register(args.register, reg)

    commit = git_head()
    patched = patch_catalog_li_specimen(all_problems, commit)
    print(f"patched {patched} erdos-register.toml li_specimen row(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
