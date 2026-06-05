#!/usr/bin/env python3
"""HuggingFace transformers competitor — executed when transformers+torch installed."""
import json
import os
import time
from pathlib import Path

out = os.environ.get(
    "PH_ML_TRANSFORMERS_OUT", "benchmarks/results/ph-ml-competitor-transformers.json"
)
report = {
    "competitor_id": "pytorch_transformers",
    "suite": "ph-ml-competitor-transformers",
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


try:
    import torch
    import transformers
except ImportError:
    report["note"] = "transformers or torch not installed"
    write_report()
    raise SystemExit(0)

report["framework_version"] = transformers.__version__
weights = Path("fixtures/ph-ml-weights")
if not (weights / "model.safetensors").is_file():
    report["note"] = "fixture weights missing"
    write_report()
    raise SystemExit(0)

try:
    from transformers import AutoModelForCausalLM

    t0 = time.perf_counter()
    model = AutoModelForCausalLM.from_pretrained(
        str(weights), trust_remote_code=True, torch_dtype=torch.float32
    )
    model.eval()
    with torch.no_grad():
        ids = torch.tensor([[97, 98]], dtype=torch.long)
        logits = model(ids).logits
    if logits.shape[-1] <= 0:
        raise RuntimeError("empty logits")
    report["cpu_sec"] = round(time.perf_counter() - t0, 6)
    report["executed"] = True
    report["validity_gate_pass"] = True
    report["validity_ratio"] = 1.0
    report["note"] = "transformers forward on ph-ml-weights fixture"
except Exception as exc:  # noqa: BLE001
    report["note"] = str(exc)[:200]

write_report()
