#!/usr/bin/env python3
"""Li ml_mlp_sgd_step_f32 training loop vs PyTorch CPU SGD — same 2-2-1 XOR fixture."""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

from ph_ml_competitor_workloads import (
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    MLP_HIDDEN,
    MLP_IN_DIM,
    MLP_OUT_DIM,
    bench_loop,
)

ROOT = Path(os.environ.get("PH_ML_TRAIN_COMP_ROOT", Path(__file__).resolve().parents[1]))
OUT = Path(
    os.environ.get(
        "PH_ML_MLP_TRAIN_COMP_OUT",
        ROOT / "benchmarks/results/ph-ml-mlp-train-competitive.json",
    )
)
SMOKE = ROOT / "packages/li-ml/li-tests/smoke/ml_mlp_train_bench.li"
STEPS = int(os.environ.get("PH_ML_TRAIN_BENCH_STEPS", str(DEFAULT_RUNS)))

report: dict = {
    "suite": "ph-ml-mlp-train-competitive",
    "workload_class": "tier3_cpu",
    "workload_note": (
        f"ml_mlp_sgd_step_f32 {MLP_IN_DIM}-{MLP_HIDDEN}-{MLP_OUT_DIM} XOR; "
        f"{STEPS} SGD steps; Li runtime autograd vs PyTorch CPU SGD"
    ),
    "in_dim": MLP_IN_DIM,
    "hidden": MLP_HIDDEN,
    "out_dim": MLP_OUT_DIM,
    "train_steps": STEPS,
    "executed": False,
    "validity_gate_pass": False,
    "li_cpu_sec": None,
    "pytorch_cpu_sec": None,
    "ratio_vs_li": None,
    "li": {"executed": False, "cpu_sec": None, "validity_gate_pass": False},
    "competitors": [],
}


def write_report() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(OUT)


def resolve_lic() -> Path | None:
    lic = os.environ.get("LIC", "").strip()
    if lic and Path(lic).is_file():
        return Path(lic)
    for candidate in (
        ROOT / "build-wsl/compiler/lic/lic",
        ROOT / "build/compiler/lic/lic",
        ROOT / "build/compiler/lic/lic.exe",
    ):
        if candidate.is_file():
            return candidate
    resolve = ROOT / "scripts/resolve-lic.sh"
    if resolve.is_file():
        try:
            out = subprocess.run(
                [str(resolve)],
                cwd=ROOT,
                capture_output=True,
                text=True,
                check=True,
            )
            p = Path(out.stdout.strip())
            if p.is_file():
                return p
        except subprocess.CalledProcessError:
            pass
    return None


def bench_li(lic: Path) -> tuple[float | None, bool]:
    if not SMOKE.is_file():
        return None, False
    smoke_rel = str(SMOKE.relative_to(ROOT))
    env = os.environ.copy()
    for cc in ("clang-22", "clang", "gcc"):
        if subprocess.run(["which", cc], capture_output=True).returncode == 0:
            env["CC"] = cc
            env["CXX"] = f"{cc}++" if cc != "clang-22" else "clang++-22"
            break
    with tempfile.TemporaryDirectory(prefix="ph-ml-train-bench-") as tmp:
        bin_path = Path(tmp) / "ml_mlp_train_bench"
        build = subprocess.run(
            [str(lic), "build", "--allow-open-vc", smoke_rel, "-o", str(bin_path)],
            cwd=ROOT,
            capture_output=True,
            text=True,
            env=env,
        )
        if build.returncode != 0 or not bin_path.is_file():
            return None, False

        def run_train():
            r = subprocess.run([str(bin_path)], cwd=ROOT, capture_output=True, text=True, env=env)
            return r.returncode

        def sanity(rc) -> bool:
            return rc == 0

        cpu_sec, err = bench_loop(DEFAULT_RUNS, DEFAULT_WARMUP, run_train, sanity)
        if err:
            return None, False
        return cpu_sec, True


def bench_pytorch() -> tuple[float | None, bool]:
    try:
        import torch
        import torch.nn.functional as F
    except ImportError:
        return None, False

    torch.set_num_threads(max(1, os.cpu_count() or 1))
    x = torch.tensor([[1.0, 1.0]], dtype=torch.float32)
    target = 0.0
    lr = 0.3
    w1 = torch.tensor([[0.5, 0.5], [0.5, 0.5]], dtype=torch.float32, requires_grad=True)
    w2 = torch.tensor([[0.5], [0.5]], dtype=torch.float32, requires_grad=True)

    def train_step():
        if w1.grad is not None:
            w1.grad.zero_()
        if w2.grad is not None:
            w2.grad.zero_()
        h = F.relu(x @ w1.T)
        y = h @ w2
        loss = (y[0, 0] - target) ** 2
        loss.backward()
        with torch.no_grad():
            w1 -= lr * w1.grad
            w2 -= lr * w2.grad
        return loss

    def sanity(loss) -> bool:
        return float(loss.item()) >= 0.0

    cpu_sec, err = bench_loop(STEPS, DEFAULT_WARMUP, train_step, sanity)
    if err:
        return None, False
    return cpu_sec, True


def main() -> int:
    lic = resolve_lic()
    li_sec, li_ok = (None, False)
    if lic is not None:
        li_sec, li_ok = bench_li(lic)

    pt_sec, pt_ok = bench_pytorch()

    report["li"] = {
        "executed": li_ok and li_sec is not None,
        "cpu_sec": li_sec,
        "validity_gate_pass": li_ok and li_sec is not None,
        "kernel": "ml.mlp_sgd_step_f32",
    }
    report["li_cpu_sec"] = li_sec

    pt_row = {
        "id": "pytorch_cpu",
        "incumbent": "PyTorch CPU SGD",
        "executed": pt_ok and pt_sec is not None,
        "cpu_sec": pt_sec,
        "validity_gate_pass": pt_ok and pt_sec is not None,
        "ratio_vs_li": None,
    }
    if li_sec and pt_sec and float(li_sec) > 0:
        pt_row["ratio_vs_li"] = round(float(pt_sec) / float(li_sec), 6)
    report["competitors"] = [pt_row]
    report["pytorch_cpu_sec"] = pt_sec
    report["ratio_vs_li"] = pt_row["ratio_vs_li"]
    report["executed"] = bool(report["li"]["executed"])
    report["validity_gate_pass"] = bool(report["li"]["executed"])
    write_report()
    return 0 if report["validity_gate_pass"] else 1


if __name__ == "__main__":
    sys.exit(main())
