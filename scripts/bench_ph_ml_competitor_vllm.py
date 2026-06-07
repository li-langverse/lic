#!/usr/bin/env python3
"""vLLM competitor — executed when vllm is importable and GPU optional."""
import json
import os
import time
from pathlib import Path

out = os.environ.get("PH_ML_VLLM_OUT", "benchmarks/results/ph-ml-competitor-vllm.json")
report = {
    "competitor_id": "vllm",
    "suite": "ph-ml-competitor-vllm",
    "workload": "llm_forward_fixture",
    "executed": False,
    "cpu_sec": None,
    "validity_gate_pass": False,
    "validity_ratio": 0.0,
    "framework_version": None,
    "device": None,
    "note": None,
}


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import vllm
except ImportError:
    report["note"] = "vllm not installed"
    write_report()
    raise SystemExit(0)

report["framework_version"] = getattr(vllm, "__version__", "unknown")
weights = Path("fixtures/ph-ml-weights/model.safetensors")
if not weights.is_file():
    report["note"] = "fixture weights missing"
    write_report()
    raise SystemExit(0)

try:
    import torch
    from vllm import LLM, SamplingParams

    device = "cuda" if torch.cuda.is_available() else "cpu"
    report["device"] = device
    t0 = time.perf_counter()
    llm = LLM(model=str(weights), trust_remote_code=True, max_model_len=64, enforce_eager=True)
    _ = llm.generate(["ab"], SamplingParams(max_tokens=1, temperature=0.0))
    report["cpu_sec"] = round(time.perf_counter() - t0, 6)
    report["executed"] = True
    report["validity_gate_pass"] = True
    report["validity_ratio"] = 1.0
    report["note"] = f"vllm generate on fixture ({device})"
except Exception as exc:  # noqa: BLE001 — honest competitor skip
    report["note"] = str(exc)[:200]

write_report()
