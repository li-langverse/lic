#!/usr/bin/env python3
"""Write li_sim_summary_v1 JSON for tier-2 physics smokes and sim harness runs."""

from __future__ import annotations

import hashlib
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REPO = Path(__file__).resolve().parents[2]
RESULTS = REPO / "benchmarks" / "results"
SCHEMA = "li_sim_summary_v1"


def git_sha() -> str:
    try:
        return (
            subprocess.check_output(
                ["git", "rev-parse", "--short", "HEAD"], cwd=REPO, text=True
            )
            .strip()
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


def params_digest(params_path: Path | None) -> str | None:
    if params_path is None or not params_path.is_file():
        return None
    h = hashlib.sha256(params_path.read_bytes()).hexdigest()
    return f"sha256:{h}"


def vertical_id_for_benchmark(benchmark: str) -> str:
    mapping = {
        "md_lennard_jones": "md_lennard_jones",
        "heat_equation_2d": "pde_heat_2d",
    }
    return mapping.get(benchmark, benchmark)


def metrics_for_benchmark(benchmark: str, verify_line: str) -> dict[str, Any]:
    value = float(verify_line.strip())
    if benchmark == "md_lennard_jones":
        return {
            "energy_drift_rel": value,
            "checksum": verify_line.strip(),
        }
    if benchmark == "heat_equation_2d":
        return {
            "checksum": verify_line.strip(),
            "stencil_checksum": value,
        }
    return {"checksum": verify_line.strip()}


def invariants_for_benchmark(benchmark: str, *, passed: bool) -> dict[str, bool]:
    if benchmark == "md_lennard_jones":
        return {"energy_drift_ok": passed}
    return {"checksum_ok": passed}


def build_summary(
    *,
    benchmark: str,
    lang: str,
    variant: str,
    verify_line: str,
    passed: bool,
    detail: str,
    params_path: Path | None = None,
    workload_class: str = "stub",
) -> dict[str, Any]:
    params = params_path or REPO / "benchmarks" / "tier2_physics" / benchmark / "params.toml"
    artifacts: dict[str, Any] = {
        "params": str(params.relative_to(REPO)) if params.is_file() else None,
        "tier_f": None,
        "tier_d": None,
    }
    if detail in ("fields", "debug", "repro"):
        artifacts["tier_f"] = f"benchmarks/results/{benchmark}/fields/"
    if detail in ("debug", "repro"):
        artifacts["tier_d"] = f"benchmarks/results/{benchmark}/tier_d/"
    if detail == "repro":
        artifacts["repro_bundle"] = f"benchmarks/results/{benchmark}/publish/"

    return {
        "schema": SCHEMA,
        "benchmark": benchmark,
        "vertical_id": vertical_id_for_benchmark(benchmark),
        "workload_class": workload_class,
        "lang": lang,
        "variant": variant,
        "output_detail": detail,
        "ok": passed,
        "git_sha": git_sha(),
        "cpu_model": "",
        "flags": "",
        "params_digest": params_digest(params if params.is_file() else None),
        "metrics": metrics_for_benchmark(benchmark, verify_line),
        "invariants": invariants_for_benchmark(benchmark, passed=passed),
        "artifacts": artifacts,
        "updated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }


def write_summary(path: Path, summary: dict[str, Any]) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(summary, indent=2) + "\n")
    return path


def default_summary_path(benchmark: str, lang: str) -> Path:
    return RESULTS / benchmark / f"{lang}.summary.json"
