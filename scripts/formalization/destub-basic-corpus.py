#!/usr/bin/env python3
"""Replace stub/placeholder statements in phase-8 basic corpus catalogs and specimens."""
from __future__ import annotations

import argparse
import importlib.util
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENTRIES = ROOT / "docs/verification/proof-database/entries"
MANIFEST_ROOT = ROOT / "docs/verification/basic-corpus"
LOOKUP_PATH = MANIFEST_ROOT / "destub_statements.py"
NOTE = "phase8-basic-corpus"


def load_lookup():
    spec = importlib.util.spec_from_file_location("destub_statements", LOOKUP_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {LOOKUP_PATH}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def toml_quote(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def patch_statement_line(block: str, entry_id: str, domain: str | None, lookup) -> tuple[str, bool]:
    m = re.search(r'^statement\s*=\s*"((?:[^"\\]|\\.)*)"', block, re.M)
    if not m:
        return block, False
    old = m.group(1).replace('\\"', '"')
    new = lookup.destub_statement(entry_id, old, domain)
    if not new or new == old:
        return block, False
    new_block = re.sub(
        r'^statement\s*=\s*"(?:[^"\\]|\\.)*"',
        f"statement = {toml_quote(new)}",
        block,
        count=1,
        flags=re.M,
    )
    return new_block, True


def parse_block_fields(block: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for key in ("id", "domain", "statement", "li_specimen"):
        m = re.search(rf'^{key}\s*=\s*"((?:[^"\\]|\\.)*)"', block, re.M)
        if m:
            fields[key] = m.group(1).replace('\\"', '"')
    return fields


def patch_toml_file(path: Path, lookup, *, planned: bool = False) -> int:
    text = path.read_text(encoding="utf-8")
    orig = text
    marker = "[[planned]]" if planned else "[[entry]]"
    parts = re.split(rf"({re.escape(marker)})", text)
    if len(parts) < 3:
        return 0
    out = [parts[0]]
    changed = 0
    for i in range(1, len(parts), 2):
        header = parts[i]
        body = parts[i + 1] if i + 1 < len(parts) else ""
        if planned or NOTE in body:
            fields = parse_block_fields(body)
            entry_id = fields.get("id", "")
            if entry_id:
                new_body, did = patch_statement_line(body, entry_id, fields.get("domain"), lookup)
                if did:
                    changed += 1
                    body = new_body
        out.append(header)
        out.append(body)
    new_text = "".join(out)
    if new_text != orig:
        path.write_text(new_text, encoding="utf-8")
    return changed


def patch_specimen_header(path: Path, entry_id: str, statement: str) -> bool:
    text = path.read_text(encoding="utf-8")
    first = text.splitlines()[0] if text else ""
    expected = f"# {entry_id}: {statement}"
    if first == expected:
        return False
    if not first.startswith(f"# {entry_id}:"):
        return False
    rest = text[len(first) :].lstrip("\n")
    path.write_text(expected + "\n" + rest, encoding="utf-8")
    return True


def sync_specimens_from_catalog(lookup) -> int:
    changed = 0
    for path in sorted(ENTRIES.glob("*-basic-corpus.toml")):
        text = path.read_text(encoding="utf-8")
        for block in re.split(r"\[\[entry\]\]", text)[1:]:
            if NOTE not in block or "li_specimen" not in block:
                continue
            fields = parse_block_fields(block)
            entry_id = fields.get("id")
            rel = fields.get("li_specimen")
            stmt = fields.get("statement")
            if not entry_id or not rel or not stmt:
                continue
            sp = ROOT / rel
            if sp.is_file() and patch_specimen_header(sp, entry_id, stmt):
                changed += 1
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="report only, no writes")
    args = parser.parse_args()
    lookup = load_lookup()

    catalog_files = sorted(ENTRIES.glob("*-basic-corpus.toml"))
    manifest_files = sorted(MANIFEST_ROOT.glob("*-basic.toml"))
    total = 0
    details: list[str] = []

    for path in catalog_files:
        if args.dry_run:
            n = 0
            text = path.read_text(encoding="utf-8")
            for block in re.split(r"\[\[entry\]\]", text)[1:]:
                if NOTE not in block:
                    continue
                fields = parse_block_fields(block)
                eid = fields.get("id", "")
                old = fields.get("statement", "")
                if eid and lookup.destub_statement(eid, old, fields.get("domain")):
                    n += 1
            if n:
                details.append(f"{path.name}: {n}")
            total += n
        else:
            n = patch_toml_file(path, lookup, planned=False)
            if n:
                details.append(f"{path.name}: {n}")
            total += n

    for path in manifest_files:
        if args.dry_run:
            n = 0
            text = path.read_text(encoding="utf-8")
            for block in re.split(r"\[\[planned\]\]", text)[1:]:
                fields = parse_block_fields(block)
                eid = fields.get("id", "")
                old = fields.get("statement", "")
                if eid and lookup.destub_statement(eid, old, fields.get("domain")):
                    n += 1
            total += n
        else:
            total += patch_toml_file(path, lookup, planned=True)

    if not args.dry_run:
        sp_changed = sync_specimens_from_catalog(lookup)
        print(f"synced {sp_changed} specimen headers")
    else:
        sp_changed = 0

    print(f"destub-basic-corpus: {total} catalog/manifest statements patched")
    for line in details:
        print(f"  {line}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
