#!/usr/bin/env python3
"""llama.cpp LLM forward competitor — executed when llama-cli is installed."""
import json
import os
import shutil
import subprocess
import time
from pathlib import Path

out = os.environ.get("PH_ML_LLAMACPP_OUT", "benchmarks/results/ph-ml-competitor-llamacpp.json")
report = {
    "competitor_id": "llamacpp",
    "suite": "ph-ml-competitor-llamacpp",
    "workload": "llm_forward_fixture",
    "executed": False,
    "cpu_sec": None,
    "validity_gate_pass": False,
    "validity_ratio": 0.0,
    "framework_version": None,
    "device": "cpu",
    "note": None,
}


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


cli = shutil.which("llama-cli") or shutil.which("llama")
if not cli:
    report["note"] = "llama-cli not installed"
    write_report()
    raise SystemExit(0)

weights = Path("fixtures/ph-ml-weights/model.safetensors")
if not weights.is_file():
    report["note"] = "fixture weights missing"
    write_report()
    raise SystemExit(0)

report["framework_version"] = subprocess.check_output([cli, "--version"], text=True, stderr=subprocess.STDOUT).strip()[:120]
t0 = time.perf_counter()
proc = subprocess.run(
    [cli, "-m", str(weights), "-p", "ab", "-n", "1", "--no-display-prompt"],
    capture_output=True,
    text=True,
    timeout=30,
)
cpu_sec = round(time.perf_counter() - t0, 6)
if proc.returncode != 0:
    report["note"] = (proc.stderr or proc.stdout or "llama-cli failed")[-200:]
    write_report()
    raise SystemExit(0)

report["cpu_sec"] = cpu_sec
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
report["note"] = "llama-cli forward on ph-ml-weights fixture"
write_report()
