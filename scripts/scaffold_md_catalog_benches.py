#!/usr/bin/env python3
"""Scaffold tier2_physics harness dirs for catalog md_* rows (WP2 fill-all)."""

from __future__ import annotations

import shutil
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
TIER2 = REPO / "benchmarks" / "tier2_physics"
TEMPLATE = TIER2 / "md_lennard_jones"

MD_IDS = [
    "md_barostat_parrinello_rahman",
    "md_constraints_rattle",
    "md_constraints_shake",
    "md_energy_drift",
    "md_init_fcc_mb",
    "md_integrator_leapfrog",
    "md_integrator_verlet",
    "md_longrange_ewald",
    "md_longrange_pme",
    "md_neighbor_cell_list",
    "md_neighbor_verlet_skin",
    "md_oracle_external",
    "md_thermostat_berendsen",
    "md_thermostat_nose_hoover",
]

MD_CORE_C = """\
/* Harness alias — shares md_lennard_jones C oracle until a bench-specific kernel lands. */
#include "../../md_lennard_jones/common/md_core.c"
"""

MD_CORE_H = """\
#include "../../md_lennard_jones/common/md_core.h"
"""

LI_MAIN = """\
extern proc li_md_kernel()
  requires true
  ensures true

def main() raises IO -> int
  requires true
  ensures result == 0
  decreases 0
=
  li_md_kernel()
  return 0
"""


def readme(bench_id: str) -> str:
    return (
        f"# {bench_id}\n\n"
        "WP2 harness stub: shares the `md_lennard_jones` C oracle (`md_core.c`) until an "
        f"`{bench_id}`-specific kernel lands. Catalog path: "
        f"`benchmarks/tier2_physics/{bench_id}`.\n"
    )


def scaffold_one(bench_id: str) -> None:
    root = TIER2 / bench_id
    root.mkdir(parents=True, exist_ok=True)
    (root / "common").mkdir(parents=True, exist_ok=True)
    (root / "cpp").mkdir(parents=True, exist_ok=True)
    (root / "li").mkdir(parents=True, exist_ok=True)
    wrote: list[str] = []
    for rel, text in (
        ("common/md_core.c", MD_CORE_C),
        ("common/md_core.h", MD_CORE_H),
        ("li/main.li", LI_MAIN),
        ("README.md", readme(bench_id)),
    ):
        path = root / rel
        if not path.is_file():
            path.write_text(text)
            wrote.append(rel)
    cpp_main = root / "cpp" / "md_main.c"
    if not cpp_main.is_file():
        shutil.copy2(TEMPLATE / "cpp" / "md_main.c", cpp_main)
        wrote.append("cpp/md_main.c")
    params = root / "params.toml"
    if not params.is_file():
        shutil.copy2(TEMPLATE / "params.toml", params)
        wrote.append("params.toml")
    if wrote:
        print(f"filled {bench_id}: {', '.join(wrote)}")
    else:
        print(f"ok {bench_id}")


def main() -> None:
    for bench_id in MD_IDS:
        scaffold_one(bench_id)
    print(f"done ({len(MD_IDS)} catalog md_* stubs)")


if __name__ == "__main__":
    main()
