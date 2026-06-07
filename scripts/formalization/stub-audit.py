#!/usr/bin/env python3
"""List proof-database stub violations (catalog statements + placeholder specimens)."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENTRIES = ROOT / "docs/verification/proof-database/entries"
PROOF_DB = ROOT / "proof-db"

NAMED_DEF = re.compile(r"^(?:def|proc|extern proc)\s+(\w+)", re.M)
STATEMENT_LINE = re.compile(r"^\s*statement\s*=", re.I)
PENDING_ONLY = re.compile(
    r"^#\s*discharge:\s*pending\s*\n#\s*formalization_status:\s*li_open\s*(?:\n|$)",
    re.M,
)


def has_named_def(text: str) -> bool:
    return any(m.group(1) != "main" for m in NAMED_DEF.finditer(text))


def is_main_only(text: str) -> bool:
    if has_named_def(text):
        return False
    non_comment = [ln for ln in text.splitlines() if ln.strip() and not ln.strip().startswith("#")]
    if not non_comment:
        return True
    if len(non_comment) <= 6:
        trivial = {"=", "requires true", "ensures result == 0", "decreases 0"}
        return all(
            ln.strip() in trivial or "def main()" in ln or "return 0" in ln for ln in non_comment
        )
    return False


def is_pending_only(text: str) -> bool:
    stripped = text.lstrip()
    if not PENDING_ONLY.match(stripped):
        return False
    rest = PENDING_ONLY.sub("", stripped, count=1).strip()
    return not rest or is_main_only(rest)


def audit_catalog() -> list[str]:
    out: list[str] = []
    for path in sorted(ENTRIES.glob("*.toml")):
        rel = path.relative_to(ROOT)
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if STATEMENT_LINE.search(line) and re.search(r"stub", line, re.I):
                out.append(f"catalog:{rel}:{i}: {line.strip()[:120]}")
    return out


def audit_specimens() -> list[str]:
    out: list[str] = []
    for path in sorted(PROOF_DB.rglob("*.li")):
        rel = path.relative_to(ROOT)
        text = path.read_text(encoding="utf-8", errors="replace")
        if is_pending_only(text):
            out.append(f"specimen:pending_only:{rel}")
            continue
        if not has_named_def(text):
            out.append(f"specimen:no_named_def:{rel}")
            continue
        if is_main_only(text):
            out.append(f"specimen:main_only:{rel}")
    return out


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help="print one violation per line (default)")
    args = parser.parse_args()

    violations = audit_catalog() + audit_specimens()
    for msg in violations:
        print(msg)
    print(f"stub-audit: {len(violations)} violation(s)", file=sys.stderr)
    return 0 if not violations else 1


if __name__ == "__main__":
    raise SystemExit(main())
