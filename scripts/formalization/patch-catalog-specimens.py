#!/usr/bin/env python3
"""Patch catalog TOML rows: set li_specimen + downgrade proved→target when no Li discharge."""
from __future__ import annotations

from pathlib import Path
from typing import Any

try:
    import tomllib
except ImportError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

ROOT = Path(__file__).resolve().parents[2]
ENTRIES = ROOT / "docs/verification/proof-database/entries"


def format_toml_value(v: Any) -> str:
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, int):
        return str(v)
    if isinstance(v, list):
        inner = ", ".join(f'"{x}"' for x in v)
        return f"[{inner}]"
    s = str(v).replace("\\", "\\\\").replace('"', '\\"')
    return f'"{s}"'


def render_entries(entries: list[dict], version: int = 1, header: str = "") -> str:
    lines = [f"version = {version}"]
    if header:
        lines.extend(["", header.rstrip(), ""])
    for e in entries:
        lines.append("[[entry]]")
        for key, val in e.items():
            if key.startswith("_"):
                continue
            lines.append(f"{key} = {format_toml_value(val)}")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def specimen_for(entry: dict) -> Path | None:
    eid = str(entry.get("id", ""))
    field = str(entry.get("field", ""))
    candidates = [
        ROOT / "proof-db" / "erdos" / "specimens" / f"{eid}.li",
        ROOT / "proof-db" / "math" / "specimens" / f"{eid}.li",
    ]
    if field:
        candidates.append(ROOT / "proof-db" / field / "specimens" / f"{eid}.li")
    for c in candidates:
        if c.is_file():
            return c
    return None


def patch_file(path: Path) -> int:
    raw = path.read_text(encoding="utf-8")
    data = tomllib.loads(raw)
    rows = data.get("entry") or []
    if isinstance(rows, dict):
        rows = [rows]
    changed = 0
    for entry in rows:
        if not isinstance(entry, dict):
            continue
        spec = specimen_for(entry)
        if not spec:
            continue
        rel = spec.relative_to(ROOT).as_posix()
        if entry.get("li_specimen") != rel:
            entry["li_specimen"] = rel
            changed += 1
        if entry.get("proof_status") == "proved" and not (entry.get("lean_thm") or "").strip():
            entry["proof_status"] = "target"
            changed += 1
    if not changed:
        return 0
    version = int(data.get("version", 1))
    header = ""
    for line in raw.splitlines():
        if line.startswith("#"):
            header += line + "\n"
        elif line.strip() and not line.startswith("version"):
            break
    path.write_text(render_entries(rows, version=version, header=header.strip()), encoding="utf-8")
    return changed


def main() -> int:
    total = 0
    for path in sorted(ENTRIES.glob("*.toml")):
        if path.name == "schema.toml":
            continue
        total += patch_file(path)
    print(f"patch-catalog-specimens: updated {total} field(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
