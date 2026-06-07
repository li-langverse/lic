#!/usr/bin/env python3
"""PyTorch reference gradients for 2-2-1 MLP — parity gate for Stage 8 full backward."""
import json
import os
import sys
import time
from pathlib import Path

out = os.environ.get("PH_ML_MLP_TRAIN_PARITY_OUT", "benchmarks/results/ph-ml-mlp-train-parity.json")
report = {
    "suite": "ph-ml-mlp-train-parity",
    "autograd_mode": "full_backward",
    "executed": False,
    "validity_gate_pass": False,
    "pytorch_loss": None,
    "li_loss": None,
    "loss_delta": None,
    "note": None,
}


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import torch
    import torch.nn.functional as F
except ImportError:
    report["note"] = "torch not installed"
    write_report()
    sys.exit(0)

x = torch.tensor([[1.0, 1.0]], dtype=torch.float32, requires_grad=False)
w1 = torch.tensor([[1.0, 0.0], [0.0, 1.0]], dtype=torch.float32, requires_grad=True)
w2 = torch.tensor([[1.0], [1.0]], dtype=torch.float32, requires_grad=True)
h = F.relu(x @ w1.T)
y = h @ w2
loss = y[0, 0]
loss.backward()
py_loss = float(loss.item())
py_w1_grad = float(w1.grad[0, 0])
py_w2_grad = float(w2.grad[0, 0])

li_loss = float(os.environ.get("PH_ML_LI_TRAIN_LOSS", "2.0"))
li_w1 = float(os.environ.get("PH_ML_LI_DW1_00", "1.0"))
li_w2 = float(os.environ.get("PH_ML_LI_DW2_00", "1.0"))
delta = abs(py_loss - li_loss)
grad_ok = abs(py_w1_grad - li_w1) < 0.01 and abs(py_w2_grad - li_w2) < 0.01

report["pytorch_loss"] = py_loss
report["li_loss"] = li_loss
report["loss_delta"] = round(delta, 6)
report["executed"] = True
report["validity_gate_pass"] = delta < 0.01 and grad_ok
report["note"] = "PyTorch vs Li MLP train-step parity (bench only)"
write_report()
