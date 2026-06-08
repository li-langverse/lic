#!/usr/bin/env python3
"""Emit li_sim_summary_v1 with QM metrics for qm_dft_scf_energy (algo_id=418)."""

from __future__ import annotations

import argparse
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
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


def build_qm_summary(
    *,
    total_energy_hartree: float,
    converged: bool,
    scf_iterations: int,
    ok: bool = True,
    method: str = "RKS/LDA",
    basis: str = "STO-3G",
    fmt: str = "json_min",
) -> dict:
    return {
        "schema": SCHEMA,
        "benchmark": "qm_dft_scf_energy",
        "vertical_id": "qm_dft",
        "algo_id": 418,
        "algo_name": "qm_dft_scf_energy",
        "workload_class": "smoke",
        "lang": "li",
        "variant": "pure_li",
        "output_detail": "summary",
        "ok": ok,
        "git_sha": git_sha(),
        "cpu_model": "",
        "flags": "",
        "params_digest": None,
        "metrics": {
            "checksum": str(total_energy_hartree),
            "checksum_f64": total_energy_hartree,
            "total_energy_hartree": total_energy_hartree,
            "converged": converged,
            "scf_iterations": scf_iterations,
            "method": method,
            "basis": basis,
        },
        "invariants": {"checksum_ok": ok, "scf_converged": converged},
        "artifacts": {
            "params": None,
            "tier_f": None,
            "tier_d": None,
        },
        "updated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }


def write_summary(path: Path, summary: dict, fmt: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    name = path.name
    for old in (".summary.json", ".summary.min.json", ".summary.yaml"):
        if name.endswith(old):
            name = name[: -len(old)]
            break
    if fmt == "json_min":
        path = path.parent / (name + ".summary.min.json")
        text = json.dumps(summary, separators=(",", ":")) + "\n"
    else:
        path = path.parent / (name + ".summary.json")
        text = json.dumps(summary, indent=2) + "\n"
    path.write_text(text)
    return path


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--total-energy-hartree", type=float, required=True)
    p.add_argument("--converged", type=int, choices=(0, 1), default=1)
    p.add_argument("--scf-iterations", type=int, default=8)
    p.add_argument("--format", choices=("json", "json_min"), default="json_min")
    p.add_argument("-o", "--output", type=Path, required=True)
    args = p.parse_args()

    summary = build_qm_summary(
        total_energy_hartree=args.total_energy_hartree,
        converged=bool(args.converged),
        scf_iterations=args.scf_iterations,
    )
    path = write_summary(args.output, summary, args.format)
    try:
        print(path.relative_to(REPO))
    except ValueError:
        print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
