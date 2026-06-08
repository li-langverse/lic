#!/usr/bin/env python3
"""WP-PAR-48 — generate main_parallel.li overlays for Li catalog benchmarks."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OVERLAY_ROOT = ROOT / "packages" / "li-parallel" / "benchmarks" / "parallel-src"

HEADER = """# li-parallel dual-mode entry (WP-PAR-48).
# Harness runs this when LI_PARALLEL=1; runtime pool + C overrides apply parallel execution.

"""


def eligible_rows(catalog_text: str) -> list[tuple[str, str]]:
    blocks = re.split(r"\n\[\[benchmark\]\]", catalog_text)
    rows: list[tuple[str, str]] = []
    for block in blocks:
        if 'repo = "lic"' not in block and "repo = 'lic'" not in block:
            continue
        if "parallel_eligible = false" in block:
            continue
        bid = re.search(r'^id = "([^"]+)"', block, re.M)
        path = re.search(r'^path = "([^"]+)"', block, re.M)
        if not bid or not path:
            continue
        if path.group(1) in ("unknown",):
            continue
        variant = re.search(r'^variant = "([^"]+)"', block, re.M)
        if variant and variant.group(1) in ("algo_registry", "db_parallel"):
            continue
        rows.append((bid.group(1), path.group(1)))
    return rows


def main() -> int:
    bench_root = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / ".cache" / "li-benchmarks"
    catalog = bench_root / "catalog.toml"
    if not catalog.is_file():
        print(f"generate-parallel-benchmark-src: missing {catalog}", file=sys.stderr)
        return 1

    created = 0
    skipped = 0
    for bid, rel in eligible_rows(catalog.read_text(encoding="utf-8")):
        main_li = bench_root / rel / "li" / "main.li"
        if not main_li.is_file():
            lic_main = ROOT / rel / "li" / "main.li"
            if lic_main.is_file():
                main_li = lic_main
            else:
                skipped += 1
                continue
        dest = OVERLAY_ROOT / rel / "li" / "main_parallel.li"
        body = main_li.read_text(encoding="utf-8")
        if body.startswith("# li-parallel dual-mode entry"):
            content = body
        else:
            content = HEADER + body
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(content, encoding="utf-8")
        created += 1

    print(f"generate-parallel-benchmark-src: wrote {created} overlay(s) under {OVERLAY_ROOT}")
    if skipped:
        print(f"generate-parallel-benchmark-src: skipped {skipped} row(s) without main.li")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
