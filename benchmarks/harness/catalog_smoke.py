#!/usr/bin/env python3
"""Compile-only smokes for catalog rows with harness.toml + li/main.li (WP4 families)."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
LIC = REPO / "build" / "compiler" / "lic" / "lic"
TIER1 = REPO / "benchmarks" / "tier1_micro"
TIER2 = REPO / "benchmarks" / "tier2_physics"

WP4_PREFIXES = ("qm_", "auto_", "ml_", "viz_")

# harness.toml template -> (tier, extern kernel, core_c relative to template dir)
TEMPLATE_BUILD: dict[str, tuple[int, str | None, str | None]] = {
    "schrodinger_1d_barrier": (2, "li_schrodinger_1d_barrier_kernel", "common/tdse_core.c"),
    "euler_fluid_2d": (2, "li_euler_fluid_2d_kernel", "common/euler_fluid_core.c"),
    "matmul_naive": (1, None, None),
    "horner_pure_li": (1, None, None),
}

PURE_LI_MAIN = """# WP4 catalog smoke ({bench_id}); family template {template}.
extern proc li_rt_volatile_sink_f64(v: float) -> unit
  requires true
  ensures true

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var acc: float = 0.0
  var i: int = 0
  while i < 4096
    acc = acc * 1.0001 + 1.0
    i = i + 1
  li_rt_volatile_sink_f64(acc)
  return 0
"""

EXTERN_LI_MAIN = """# WP4 catalog smoke ({bench_id}); family template {template}.
extern proc {kernel}()
  requires true
  ensures true

def main() raises IO -> int
  requires true
  ensures result == 0
  decreases 0
=
  {kernel}()
  return 0
"""


def parse_harness_toml(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    out: dict[str, str] = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        out[key.strip()] = val.strip().strip('"')
    return out


def tier_root(tier: int) -> Path:
    return TIER1 if tier == 1 else TIER2


def wp4_bench_dirs() -> list[Path]:
    dirs: list[Path] = []
    for root in (TIER1, TIER2):
        if not root.is_dir():
            continue
        for child in sorted(root.iterdir()):
            if not child.is_dir():
                continue
            if any(child.name.startswith(p) for p in WP4_PREFIXES):
                dirs.append(child)
    return dirs


def write_main_li(bench_dir: Path, *, bench_id: str, template: str) -> None:
    tier, kernel, _core = TEMPLATE_BUILD[template]
    li_dir = bench_dir / "li"
    li_dir.mkdir(parents=True, exist_ok=True)
    main = li_dir / "main.li"
    if kernel:
        main.write_text(
            EXTERN_LI_MAIN.format(bench_id=bench_id, template=template, kernel=kernel),
            encoding="utf-8",
        )
    else:
        main.write_text(
            PURE_LI_MAIN.format(bench_id=bench_id, template=template),
            encoding="utf-8",
        )


def lic_build_smoke(bench_dir: Path) -> tuple[bool, str]:
    if not LIC.is_file():
        return False, "lic missing"
    harness_path = bench_dir / "harness.toml"
    if not harness_path.is_file():
        return False, "harness.toml missing"
    meta = parse_harness_toml(harness_path)
    template = meta.get("template", "")
    if template not in TEMPLATE_BUILD:
        return False, f"unknown template {template!r}"
    tier, kernel, core_rel = TEMPLATE_BUILD[template]
    li_main = bench_dir / "li" / "main.li"
    if not li_main.is_file():
        return False, "li/main.li missing"
    env = {**os.environ, "LIC": str(LIC)}
    if kernel and core_rel:
        tpl_dir = tier_root(tier) / template
        extra = tpl_dir / core_rel
        if not extra.is_file():
            return False, f"template core missing: {extra.relative_to(REPO)}"
        env["LI_EXTRA_C"] = str(extra)
    cmd = [
        str(LIC),
        "build",
        "--allow-open-vc",
        "--no-lean-verify",
        str(li_main),
        "-o",
        "/dev/null",
    ]
    proc = subprocess.run(cmd, cwd=REPO, env=env, capture_output=True, text=True)
    if proc.returncode != 0:
        detail = (proc.stderr or proc.stdout or "").strip().splitlines()
        return False, detail[-1] if detail else f"exit {proc.returncode}"
    return True, "ok"


def run_wp4_catalog_smoke(*, only: set[str] | None = None) -> list[tuple[str, bool, str]]:
    results: list[tuple[str, bool, str]] = []
    for bench_dir in wp4_bench_dirs():
        name = bench_dir.name
        if only and name not in only:
            continue
        passed, detail = lic_build_smoke(bench_dir)
        results.append((name, passed, detail))
        status = "PASS" if passed else "FAIL"
        print(f"{status} catalog-smoke {name}: {detail}")
    return results


def ensure_wp4_main_li() -> int:
    """Generate li/main.li for WP4 dirs that only have harness.toml today."""
    written = 0
    for bench_dir in wp4_bench_dirs():
        harness_path = bench_dir / "harness.toml"
        if not harness_path.is_file():
            continue
        meta = parse_harness_toml(harness_path)
        template = meta.get("template", "")
        if template not in TEMPLATE_BUILD:
            print(f"skip {bench_dir.name}: unknown template {template!r}", flush=True)
            continue
        main = bench_dir / "li" / "main.li"
        if main.is_file():
            continue
        write_main_li(bench_dir, bench_id=bench_dir.name, template=template)
        written += 1
        print(f"wrote {main.relative_to(REPO)}", flush=True)
    print(f"ensure_wp4_main_li: wrote={written}")
    return 0
