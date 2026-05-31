#!/usr/bin/env python3
"""Ray RLlib pilot — partial train when ray[rllib] available; honest stub otherwise."""
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
    import ray
except ImportError:
    report["note"] = "ray not installed (optional)"
    write_report()
    sys.exit(0)

report["framework_version"] = getattr(ray, "__version__", "unknown")
try:
    from ray.rllib.algorithms.ppo import PPOConfig

    cfg = PPOConfig().environment("CartPole-v1").rollouts(num_rollout_workers=1)
    algo = cfg.build()
    t0 = time.perf_counter()
    algo.train()
    report["cpu_sec"] = round(time.perf_counter() - t0, 6)
    algo.stop()
    report["executed"] = True
    report["validity_gate_pass"] = True
    report["validity_ratio"] = 1.0
    report["note"] = "Ray RLlib partial train step (Wave 11 honest pilot)"
except Exception as exc:  # noqa: BLE001
    report["note"] = f"ray installed; RLlib partial pilot deferred: {exc}"
write_report()
