#!/usr/bin/env python3
"""SB3 SubprocVecEnv pattern smoke — honest executed:false when gymnasium missing."""
import json
import os
import sys
import time
from pathlib import Path

out = os.environ["PH_ML_SB3_VECENV_OUT"]
report = {
    "competitor_id": "sb3_vecenv",
    "suite": "ph-ml-competitor-sb3-vecenv",
    "workload": "async_env_collect_4",
    "executed": False,
    "cpu_sec": None,
    "validity_gate_pass": None,
    "validity_ratio": None,
    "framework_version": None,
    "device": "cpu",
    "workload_size": 4,
    "note": "documented pattern",
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
}


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import stable_baselines3  # noqa: F401
    import gymnasium  # noqa: F401
except ImportError:
    report["note"] = "stable_baselines3/gymnasium not installed (Wave 9 optional)"
    write_report()
    sys.exit(0)

report["note"] = "SB3 installed; full SubprocVecEnv bench deferred Wave 10"
report["framework_version"] = stable_baselines3.__version__
write_report()
