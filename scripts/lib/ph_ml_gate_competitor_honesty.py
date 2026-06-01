#!/usr/bin/env python3
"""PH-ML competitor bench honesty checks for gate scripts.

Default: optional competitors may record executed:false with a documented note.
Opt-in (PH_ML_REQUIRE_SB3=1, PH_ML_REQUIRE_RAY=1, PH_ML_REQUIRE_GPU=1): require executed:true.
When executed:true, require validity_gate_pass:true.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Any


def _truthy(name: str) -> bool:
    return os.environ.get(name, "").strip() in ("1", "true", "yes")


def _load(path: Path) -> dict[str, Any]:
    if not path.is_file():
        sys.exit(f"missing bench JSON: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def check_competitor_json(
    path: Path,
    *,
    label: str,
    require_executed: bool,
    import_probe: str | None = None,
) -> None:
    if import_probe:
        try:
            __import__(import_probe)
        except ImportError:
            return

    data = _load(path)
    executed = bool(data.get("executed"))
    note = (data.get("note") or "").strip()

    if require_executed:
        if not executed:
            sys.exit(f"{label}: executed:true required (set {import_probe or 'PH_ML_REQUIRE_*'}=0 to allow skip)")
        if not data.get("validity_gate_pass"):
            sys.exit(f"{label}: validity_gate_pass must be true when executed")
        return

    if executed:
        if not data.get("validity_gate_pass"):
            sys.exit(f"{label}: validity_gate_pass must be true when executed:true")
        return

    if not note:
        sys.exit(
            f"{label}: executed:false requires a documented note "
            f"(or set PH_ML_REQUIRE_*=1 to require execution)"
        )


def check_sb3_vecenv(results_dir: Path) -> None:
    path = results_dir / "ph-ml-competitor-sb3-vecenv.json"
    check_competitor_json(
        path,
        label="sb3_vecenv",
        require_executed=_truthy("PH_ML_REQUIRE_SB3"),
        import_probe="stable_baselines3",
    )


def check_ray_rllib(results_dir: Path) -> None:
    path = results_dir / "ph-ml-competitor-ray-rllib.json"
    check_competitor_json(
        path,
        label="ray_rllib",
        require_executed=_truthy("PH_ML_REQUIRE_RAY"),
        import_probe="ray",
    )


def check_pytorch_cuda_matmul(results_dir: Path) -> None:
    if not _truthy("PH_ML_REQUIRE_GPU"):
        return
    path = results_dir / "ph-ml-competitor-pytorch-cuda-matmul.json"
    check_competitor_json(
        path,
        label="pytorch_cuda_matmul",
        require_executed=True,
    )


def main() -> int:
    results = Path(os.environ.get("BENCHMARKS_RESULTS", "benchmarks/results"))
    which = (os.environ.get("PH_ML_GATE_COMPETITOR_CHECK") or "all").strip().lower()
    if which in ("all", "sb3"):
        check_sb3_vecenv(results)
    if which in ("all", "ray"):
        check_ray_rllib(results)
    if which in ("all", "gpu"):
        check_pytorch_cuda_matmul(results)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
