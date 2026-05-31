#!/usr/bin/env python3
"""Real OS subprocess env IPC for Wave 12."""
import json
import multiprocessing as mp
import os
import sys
import time
from pathlib import Path

out = os.environ.get("PH_ML_RL_IPC_FORK_OUT", "benchmarks/results/ph-ml-rl-env-ipc-fork.json")

def child_step(_):
    return 1.0

def parent_collect(n, method):
    ctx = mp.get_context(method)
    with ctx.Pool(n) as pool:
        return sum(pool.map(child_step, range(n)))

report = {
    "suite": "ph-ml-rl-env-ipc-fork",
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "executed": False,
    "validity_gate_pass": False,
    "ipc_method": "spawn",
    "note": "multiprocessing pilot",
}
try:
    method = "spawn"
    if sys.platform != "win32" and os.environ.get("PH_ML_RL_IPC_FORCE_SPAWN", "0") != "1":
        try:
            mp.get_context("fork")
            method = "fork"
        except (ValueError, OSError):
            method = "spawn"
    t0 = time.perf_counter()
    r = parent_collect(4, method)
    report["cpu_sec"] = round(time.perf_counter() - t0, 6)
    report["ipc_method"] = method
    report["executed"] = r == 4.0
    report["validity_gate_pass"] = report["executed"]
    report["validity_ratio"] = 1.0 if report["executed"] else 0.0
    report["note"] = "multiprocessing %s x4 (Wave 12)" % method
except Exception as exc:
    report["note"] = str(exc)[:300]
Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(out)
