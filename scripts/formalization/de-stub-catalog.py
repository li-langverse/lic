#!/usr/bin/env python3
"""Patch catalog TOML statements: basic-corpus destub lookup + cross-field stub replacements."""
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

# Non-basic-corpus catalog rows that still carry "(modeling stub)" / "(scalar stub)" labels.
GENERAL_STUB_MAP: dict[str, str] = {
    "Protein folding energy landscape: native state minimizes effective free energy (modeling stub).": (
        "Protein folding energy landscape: native conformation R* minimizes effective free energy "
        "E(R) over admissible conformations R."
    ),
    "Pairwise alignment score is additive over matched columns under substitution matrix S (modeling stub).": (
        "Pairwise alignment score Score(A,B) = sum_i S(a_i, b_i) over matched columns with "
        "substitution matrix S."
    ),
    "Hartree-Fock: variational ground-state energy under single-determinant ansatz (modeling stub).": (
        "Hartree-Fock variational principle: E_HF = min_{psi in SD} <psi|H|psi> over single-determinant "
        "ansatz psi."
    ),
    "SCF energy functional E_k at iteration k is well-defined on the HF/DFT ansatz (modeling stub).": (
        "SCF energy functional E_k = <psi_k|F(psi_k)|psi_k> is well-defined at Hartree-Fock/DFT "
        "iteration k."
    ),
    "Newton II: net force equals mass times acceleration (scalar stub).": (
        "Newton II: net force F_net equals mass m times acceleration a (F_net = m a)."
    ),
}


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


def destub_statement(entry_id: str, statement: str, domain: str | None, lookup) -> str | None:
    if statement in GENERAL_STUB_MAP:
        return GENERAL_STUB_MAP[statement]
    return lookup.destub_statement(entry_id, statement, domain)


def parse_block_fields(block: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for key in ("id", "domain", "statement", "li_specimen"):
        m = re.search(rf'^{key}\s*=\s*"((?:[^"\\]|\\.)*)"', block, re.M)
        if m:
            fields[key] = m.group(1).replace('\\"', '"')
    return fields


def patch_statement_line(block: str, entry_id: str, domain: str | None, lookup) -> tuple[str, bool]:
    m = re.search(r'^statement\s*=\s*"((?:[^"\\]|\\.)*)"', block, re.M)
    if not m:
        return block, False
    old = m.group(1).replace('\\"', '"')
    new = destub_statement(entry_id, old, domain, lookup)
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
        fields = parse_block_fields(body)
        entry_id = fields.get("id", "")
        if entry_id:
            if planned or NOTE in body or re.search(r"stub", body, re.I):
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


def patch_all_catalogs(lookup, *, dry_run: bool = False) -> int:
    total = 0
    for path in sorted(ENTRIES.glob("*.toml")):
        if dry_run:
            text = path.read_text(encoding="utf-8")
            n = 0
            for block in re.split(r"\[\[entry\]\]", text)[1:]:
                fields = parse_block_fields(block)
                eid = fields.get("id", "")
                old = fields.get("statement", "")
                if eid and destub_statement(eid, old, fields.get("domain"), lookup):
                    n += 1
            total += n
        else:
            total += patch_toml_file(path, lookup, planned=False)
    for path in sorted(MANIFEST_ROOT.glob("*-basic.toml")):
        if not dry_run:
            total += patch_toml_file(path, lookup, planned=True)
    return total


def sync_specimen_headers(lookup) -> int:
    changed = 0
    for path in sorted(ENTRIES.glob("*.toml")):
        text = path.read_text(encoding="utf-8")
        for block in re.split(r"\[\[entry\]\]", text)[1:]:
            fields = parse_block_fields(block)
            entry_id = fields.get("id")
            rel = fields.get("li_specimen")
            stmt = fields.get("statement")
            if not entry_id or not rel or not stmt:
                continue
            sp = ROOT / rel
            if not sp.is_file():
                continue
            text_sp = sp.read_text(encoding="utf-8")
            first = text_sp.splitlines()[0] if text_sp else ""
            expected = f"# {entry_id}: {stmt}"
            if first != expected and first.startswith(f"# {entry_id}:"):
                rest = text_sp[len(first) :].lstrip("\n")
                sp.write_text(expected + "\n" + rest, encoding="utf-8")
                changed += 1
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    lookup = load_lookup()
    n = patch_all_catalogs(lookup, dry_run=args.dry_run)
    print(f"de-stub-catalog: {n} statement(s) {'would be ' if args.dry_run else ''}patched")
    if not args.dry_run:
        print(f"synced {sync_specimen_headers(lookup)} specimen header(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
