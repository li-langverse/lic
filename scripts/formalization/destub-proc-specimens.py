#!/usr/bin/env python3
"""Convert proof-db extern proc stubs to def (site-visible specimens must not use proc)."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PROOF_DB = ROOT / "proof-db"

OPEN_WITNESS_BLOCK = re.compile(
    r"\nextern proc \w+_open_witness\(\) -> int\n"
    r"  requires true\n"
    r"  ensures result == 0\n"
    r"  decreases 0\n",
    re.M,
)

EXTERN_PROC_HEAD = re.compile(
    r"^(\s*)extern proc (\w+)\(([^)]*)\)([^=\n]*)\n((?:  .*\n)*?)(?=\n(?:def |extern |#|$))",
    re.M,
)


def default_return(ret: str) -> str:
    ret = ret.strip()
    if ret == "float":
        return "0.0"
    if ret in ("int", "bool"):
        return "0"
    if ret in ("unit", "void"):
        return "()"
    return "0"


def convert_extern_proc_blocks(text: str) -> str:
    def repl(m: re.Match[str]) -> str:
        indent, name, params, ret_tail, body = m.groups()
        ret = ret_tail.strip().lstrip("->").strip() or "int"
        lines = body.rstrip("\n").splitlines()
        if not lines:
            contract = [
                f"{indent}def {name}({params}){ret_tail.strip()}",
                f"{indent}  requires true",
                f"{indent}  ensures true",
                f"{indent}  decreases 0",
            ]
        else:
            contract = [f"{indent}def {name}({params}){ret_tail.strip()}"] + lines
        if not any(ln.strip() == "=" for ln in contract):
            contract.extend(
                [
                    f"{indent}=",
                    f"{indent}  return {default_return(ret)}",
                ]
            )
        return "\n".join(contract) + "\n"

    prev = None
    while prev != text:
        prev = text
        text = EXTERN_PROC_HEAD.sub(repl, text)
    return text


def migrate_text(text: str) -> str:
    text = OPEN_WITNESS_BLOCK.sub("\n", text)
    text = convert_extern_proc_blocks(text)
    return text


def migrate_file(path: Path, *, dry_run: bool) -> bool:
    original = path.read_text(encoding="utf-8")
    updated = migrate_text(original)
    if updated == original:
        return False
    if not dry_run:
        path.write_text(updated, encoding="utf-8")
    return True


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    changed = 0
    for path in sorted(PROOF_DB.rglob("*.li")):
        if migrate_file(path, dry_run=args.dry_run):
            changed += 1
    action = "would migrate" if args.dry_run else "migrated"
    print(f"destub-proc-specimens: {action} {changed} file(s) under {PROOF_DB}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
