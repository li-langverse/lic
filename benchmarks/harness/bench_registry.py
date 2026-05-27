#!/usr/bin/env python3
"""Family-template timings for algo_registry rows without dedicated harness dirs."""

from __future__ import annotations

import json
from pathlib import Path

from bench import (
    REPO,
    TIER1_BENCHES,
    TIER2_BENCHES,
    BenchSpec,
    merge_rows,
    read_csv,
    run_tier_benches,
    write_csv,
    RESULTS,
)

REGISTRY_PATH = REPO / "benchmarks" / "competitive" / "algo_registry.json"

# Registry family -> existing harness id (must exist in TIER1_BENCHES or TIER2_BENCHES).
FAMILY_TEMPLATE: dict[str, str] = {
    "num": "matmul_naive",
    "md": "md_lennard_jones",
    "pde": "heat_equation_2d",
    "rigid": "heat_equation_2d",
    "robo": "three_body",
    "am": "advection_diffusion_2d",
    "qm": "heat_equation_2d",
    "auto": "advection_diffusion_2d",
    "ml": "matmul_naive",
    "viz": "reduce_sum",
    "bio": "heat_equation_2d",
    "drug": "heat_equation_2d",
}

_NATIVE_BY_NAME: dict[str, BenchSpec] = {
    s.name: s for s in (*TIER1_BENCHES, *TIER2_BENCHES)
}
_TEMPLATE_BY_REGISTRY_ID: dict[str, str] = {}


def load_registry_names() -> list[dict]:
    if not REGISTRY_PATH.is_file():
        return []
    doc = json.loads(REGISTRY_PATH.read_text())
    return list(doc.get("algorithms", []))


def registry_alias_specs(*, skip_existing: bool = True) -> tuple[BenchSpec, ...]:
    """BenchSpec rows that time a family template but emit CSV under registry ids."""
    specs: list[BenchSpec] = []
    _TEMPLATE_BY_REGISTRY_ID.clear()
    for entry in load_registry_names():
        name = str(entry.get("name", "")).strip()
        if not name:
            continue
        if skip_existing and name in _NATIVE_BY_NAME:
            continue
        family = str(entry.get("family", "")).strip()
        template_name = FAMILY_TEMPLATE.get(family)
        if not template_name:
            continue
        base = _NATIVE_BY_NAME.get(template_name)
        if base is None:
            continue
        _TEMPLATE_BY_REGISTRY_ID[name] = template_name
        specs.append(
            BenchSpec(
                name=name,
                tier=base.tier,
                rel_dir=base.rel_dir,
                main_c=base.main_c,
                core_c=base.core_c,
                li_main=base.li_main,
                flops_per_run=base.flops_per_run,
                bytes_per_run=base.bytes_per_run,
                li_pure=base.li_pure,
            )
        )
    return tuple(specs)


def clone_template_csv_rows(
    specs: tuple[BenchSpec, ...], *, out: Path = RESULTS / "latest.csv"
) -> int:
    """Duplicate template timing rows under registry ids (same kernel, catalog coverage)."""
    import os

    merged = read_csv(out)
    by_bench: dict[str, list[dict]] = {}
    for row in merged:
        by_bench.setdefault(row["benchmark"], []).append(row)

    added = 0
    for spec in specs:
        template = _TEMPLATE_BY_REGISTRY_ID.get(spec.name)
        if not template:
            continue
        src = by_bench.get(template)
        if not src:
            print(f"registry: skip {spec.name} (no CSV for template {template})", flush=True)
            continue
        new_rows: list[dict[str, object]] = []
        for row in src:
            new_row = dict(row)
            new_row["benchmark"] = spec.name
            flags = str(row.get("flags", ""))
            if "family-template" not in flags:
                new_row["flags"] = f"{flags} family-template={template}".strip()
            new_rows.append(new_row)
        merged = merge_rows(merged, new_rows, benchmark=spec.name)
        added += len(new_rows)

    if added:
        write_csv(out, merged)
    print(f"registry: cloned {added} CSV rows for {len(specs)} aliases -> {out}")
    return 0 if added else 1


def run_registry_family_benches(
    *,
    runs: int = 3,
    out: Path = RESULTS / "latest.csv",
    verify: bool = False,
    only: set[str] | None = None,
) -> int:
    import os

    specs = registry_alias_specs()
    if only:
        specs = tuple(s for s in specs if s.name in only)
    if not specs:
        print("registry: no alias specs in scope")
        return 0

    if os.environ.get("REGISTRY_RUN_TIMINGS", "").strip() not in ("1", "true", "yes"):
        return clone_template_csv_rows(specs, out=out)

    print(f"registry: running {len(specs)} family-template timing aliases")
    return run_tier_benches(
        specs, runs=runs, out=out, verify=verify, label="registry-family"
    )
