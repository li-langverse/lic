#!/usr/bin/env python3
"""Create minimal per-id harness dirs (params + manifest) for algo_registry catalog rows."""

from __future__ import annotations

import json
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
REGISTRY = REPO / "benchmarks" / "competitive" / "algo_registry.json"
TIER1 = REPO / "benchmarks" / "tier1_micro"
TIER2 = REPO / "benchmarks" / "tier2_physics"

FAMILY_TEMPLATE: dict[str, tuple[str, int]] = {
    "num": ("matmul_naive", 1),
    "md": ("md_lennard_jones", 2),
    "pde": ("heat_equation_2d", 2),
    "rigid": ("heat_equation_2d", 2),
    "robo": ("three_body", 2),
    "am": ("advection_diffusion_2d", 2),
    "qm": ("heat_equation_2d", 2),
    "auto": ("advection_diffusion_2d", 2),
    "ml": ("matmul_naive", 1),
    "viz": ("reduce_sum", 1),
    "bio": ("heat_equation_2d", 2),
    "drug": ("heat_equation_2d", 2),
}

MANIFEST = """# Generated family-template harness (orchestration via bench_registry.py).
template = "{template}"
family = "{family}"
"""


def existing_harness_ids() -> set[str]:
    ids: set[str] = set()
    for root in (TIER1, TIER2):
        if not root.is_dir():
            continue
        for child in root.iterdir():
            if child.is_dir():
                ids.add(child.name)
    return ids


def main() -> int:
    doc = json.loads(REGISTRY.read_text())
    have = existing_harness_ids()
    created = 0
    skipped = 0
    for entry in doc.get("algorithms", []):
        name = entry["name"]
        if name in have:
            skipped += 1
            continue
        family = entry.get("family", "")
        tpl = FAMILY_TEMPLATE.get(family)
        if not tpl:
            continue
        template, tier = tpl
        root = TIER1 if tier == 1 else TIER2
        bench_dir = root / name
        if bench_dir.exists():
            skipped += 1
            continue
        bench_dir.mkdir(parents=True)
        (bench_dir / "harness.toml").write_text(
            MANIFEST.format(template=template, family=family),
            encoding="utf-8",
        )
        params_src = root / template / "params.toml"
        if params_src.is_file():
            (bench_dir / "params.toml").write_text(
                f"# Family template: {template}\n{params_src.read_text()}",
                encoding="utf-8",
            )
        else:
            (bench_dir / "params.toml").write_text(
                f'# Family template: {template}\nN = 256\n',
                encoding="utf-8",
            )
        created += 1
    print(f"generate-registry-harnesses: created={created} skipped={skipped}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
