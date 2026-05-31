#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
REGISTRY="$BENCHMARKS_COMPETITIVE/ph-ml.toml"
OUT="$BENCHMARKS_RESULTS/ph-ml-competitive.json"
mkdir -p "$BENCHMARKS_RESULTS"

bash "$ROOT/scripts/bench-ph-ml-lkir-matmul.sh"
bash "$ROOT/scripts/bench-ph-ml-mlp-forward.sh"
bash "$ROOT/scripts/bench-ph-ml-async-env-collect.sh"
bash "$ROOT/scripts/bench-ph-ml-llm-forward.sh"

export PH_ML_COMP_ROOT="$ROOT" PH_ML_COMP_OUT="$OUT" PH_ML_COMP_REGISTRY="$REGISTRY"
python3 <<'PY'
import json, os, time
from pathlib import Path

root = Path(os.environ["PH_ML_COMP_ROOT"])
out = Path(os.environ["PH_ML_COMP_OUT"])
registry = os.environ["PH_ML_COMP_REGISTRY"]

def load_json(name):
    p = Path(os.environ["BENCHMARKS_RESULTS"]) / name
    if p.is_file():
        return json.loads(p.read_text())
    return {}

matmul = load_json("ph-ml-lkir-matmul.json")
mlp = load_json("ph-ml-mlp-forward.json")
async_env = load_json("ph-ml-async-env-collect.json")
llm = load_json("ph-ml-llm-forward.json")

def li_row(src, workload_class):
    return {
        "id": "li",
        "incumbent": "Li native",
        "workload_class": workload_class,
        "executed": bool(src.get("executed")),
        "cpu_sec": src.get("cpu_sec"),
        "validity_gate_pass": src.get("validity_gate_pass"),
        "validity_ratio": src.get("validity_ratio", 1.0 if src.get("validity_gate_pass") else 0.0),
        "ratio_vs_li": 1.0,
    }

def competitor(cid, incumbent, workload_class, note):
    return {
        "id": cid,
        "incumbent": incumbent,
        "workload_class": workload_class,
        "executed": False,
        "cpu_sec": None,
        "validity_gate_pass": None,
        "validity_ratio": None,
        "ratio_vs_li": None,
        "note": note,
    }

rows = [
    {
        "id": "matmul_lkir",
        "kernel": "ml.lkir.matmul_f32",
        "workload_class": "pilot" if matmul.get("executed") else "stub",
        "executed": bool(matmul.get("executed")),
        "li": li_row(matmul, "pilot"),
        "competitors": [
            competitor("cpp_openmp", "C++/OpenMP matmul_blocked", "reference_native", "tier-2 cpp column"),
            competitor("rust_ndarray_rayon", "Rust/ndarray+rayon matmul_blocked", "shared_c_kernel", "tier-2 rust column"),
            competitor("python_numpy", "NumPy @ matmul (BLAS)", "blas_labeled", "BLAS-backed; not naive Python"),
        ],
    },
    {
        "id": "mlp_forward",
        "kernel": "ml.mlp_forward_f32",
        "workload_class": "pilot" if mlp.get("executed") else "stub",
        "executed": bool(mlp.get("executed")),
        "li": li_row(mlp, "pilot"),
        "competitors": [
            competitor("cpp_openmp", "C++ reference MLP forward", "reference_native", "tier-1 ml_mlp_forward catalog"),
            competitor("python_numpy", "PyTorch CPU nn.Linear stack", "blas_labeled", "incumbent ML stack"),
        ],
    },
    {
        "id": "async_env_collect",
        "kernel": "ml.rl.async_env_collect",
        "workload_class": "pilot",
        "executed": bool(async_env.get("executed")),
        "li": {
            **li_row(async_env, "pilot"),
            "worker": async_env.get("worker"),
            "worker_count": async_env.get("worker_count"),
            "parallelism_model": async_env.get("parallelism_model"),
        },
        "competitors": [
            competitor("sb3_vecenv", "Stable-Baselines3 SubprocVecEnv", "stub", "Documented VecEnv pattern"),
            competitor("ray_rllib", "Ray RLlib RolloutWorker", "stub", "Documented RLlib sample collection"),
        ],
    },
    {
        "id": "llm_forward",
        "kernel": "llm.forward_stub",
        "workload_class": "stub",
        "executed": bool(llm.get("executed")),
        "li": li_row(llm, "stub"),
        "competitors": [
            competitor("llamacpp", "llama.cpp CPU forward", "stub", "No fixture weights parse yet"),
            competitor("vllm", "vLLM batched forward", "stub", "GPU serving; out of scope"),
            competitor("pytorch_transformers", "PyTorch transformers forward", "stub", "External oracle TBD"),
        ],
    },
]

report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-ml-competitive",
    "registry_path": registry,
    "registry_schema": "li_ph_ml_competitive_v1",
    "rows": rows,
}
out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-competitive: done"
