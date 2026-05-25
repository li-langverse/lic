#!/usr/bin/env python3
"""WP4: materialize tier1/tier2 harness dirs + li/main.li for qm_*, auto_*, ml_*, viz_*."""

from __future__ import annotations

import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "benchmarks" / "harness"))

from catalog_smoke import (  # noqa: E402
    TEMPLATE_BUILD,
    ensure_wp4_main_li,
    tier_root,
    write_main_li,
)

REGISTRY = REPO / "benchmarks" / "competitive" / "algo_registry.json"
TIER1 = REPO / "benchmarks" / "tier1_micro"
TIER2 = REPO / "benchmarks" / "tier2_physics"

FAMILY_TEMPLATE: dict[str, str] = {
    "qm": "schrodinger_1d_barrier",
    "auto": "euler_fluid_2d",
    "ml": "matmul_naive",
    "viz": "horner_pure_li",
}

MANIFEST = """# WP4 catalog smoke (bench_registry family template).
template = "{template}"
family = "{family}"
"""

WP4_FAMILIES = frozenset(FAMILY_TEMPLATE.keys())


def existing_ids() -> set[str]:
    ids: set[str] = set()
    for root in (TIER1, TIER2):
        if root.is_dir():
            ids.update(p.name for p in root.iterdir() if p.is_dir())
    return ids


def main() -> int:
    doc = json.loads(REGISTRY.read_text(encoding="utf-8"))
    created_dirs = 0
    for entry in doc.get("algorithms", []):
        name = entry["name"]
        family = entry.get("family", "")
        if family not in WP4_FAMILIES:
            continue
        template = FAMILY_TEMPLATE[family]
        tier, _, _ = TEMPLATE_BUILD[template]
        root = tier_root(tier)
        bench_dir = root / name
        if not bench_dir.exists():
            bench_dir.mkdir(parents=True)
            (bench_dir / "harness.toml").write_text(
                MANIFEST.format(template=template, family=family),
                encoding="utf-8",
            )
            tpl_params = root / template / "params.toml"
            if tpl_params.is_file():
                (bench_dir / "params.toml").write_text(
                    f"# Family template: {template}\n{tpl_params.read_text(encoding='utf-8')}",
                    encoding="utf-8",
                )
            else:
                (bench_dir / "params.toml").write_text(
                    f"# Family template: {template}\nN = 256\n",
                    encoding="utf-8",
                )
            created_dirs += 1
        main = bench_dir / "li" / "main.li"
        if not main.is_file():
            write_main_li(bench_dir, bench_id=name, template=template)

    ensure_wp4_main_li()
    print(
        f"generate-wp4-catalog-smokes: new_dirs={created_dirs} "
        f"wp4_ids={sum(1 for e in doc['algorithms'] if e.get('family') in WP4_FAMILIES)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
