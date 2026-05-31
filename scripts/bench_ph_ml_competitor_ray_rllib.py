#!/usr/bin/env python3
"""Ray RLlib RolloutWorker pattern — honest stub (ray[rllib] too heavy for tier-0 gate)."""
import json
import os
import sys
import time
from pathlib import Path

from ph_ml_competitor_workloads import report_base

out = os.environ["PH_ML_RAY_RLLIB_OUT"]
report = report_base("ray_rllib", "ph-ml-competitor-ray-rllib", "async_env_collect_4")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["device"] = "cpu"
report["workload_size"] = 4
report["note"] = "Ray RLlib pattern documented; full rollout bench deferred (heavy dep)"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import ray  # noqa: F401
    report["framework_version"] = getattr(ray, "__version__", "unknown")
    report["note"] = "ray installed; RLlib RolloutWorker bench deferred — see docs/game-dev/PH-ML-GPU-battle-plan.md"
except ImportError:
    report["note"] = "ray not installed (optional)"
write_report()
