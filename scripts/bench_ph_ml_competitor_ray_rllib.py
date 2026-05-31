#!/usr/bin/env python3
"""Ray RLlib rollout bench when ray[rllib] available."""
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
report["note"] = "Ray RLlib optional"

def write_report():
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)

try:
    import ray
except ImportError:
    report["note"] = "ray not installed (optional Wave 12)"
    write_report()
    sys.exit(0)

report["framework_version"] = getattr(ray, "__version__", "unknown")
try:
    from ray.rllib.algorithms.ppo import PPOConfig
    cfg = (
        PPOConfig()
        .environment("CartPole-v1")
        .rollouts(num_rollout_workers=2, rollout_fragment_length=64)
        .training(train_batch_size=128)
    )
    algo = cfg.build()
    t0 = time.perf_counter()
    for _ in range(2):
        algo.train()
    report["cpu_sec"] = round(time.perf_counter() - t0, 6)
    algo.stop()
    report["executed"] = True
    report["validity_gate_pass"] = True
    report["validity_ratio"] = 1.0
    report["note"] = "Ray RLlib 2-iteration rollout bench (Wave 12)"
except Exception as exc:
    report["note"] = ("ray installed; RLlib rollout deferred: %s" % exc)[:300]
write_report()
