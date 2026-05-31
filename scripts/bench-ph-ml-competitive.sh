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
bash "$ROOT/scripts/bench-ph-ml-competitor-numpy-matmul.sh"
export PH_ML_COMP_ROOT="$ROOT" PH_ML_COMP_OUT="$OUT" PH_ML_COMP_REGISTRY="$REGISTRY"
python3 <<'PY'
import json, os, time
from pathlib import Path
root = Path(os.environ["PH_ML_COMP_ROOT"])
out = Path(os.environ["PH_ML_COMP_OUT"])

def load(name):
    p = Path(os.environ["BENCHMARKS_RESULTS"]) / name
    return json.loads(p.read_text()) if p.is_file() else {}

def li_row(src, wc):
    return {"id": "li", "incumbent": "Li native", "workload_class": wc, "executed": bool(src.get("executed")), "cpu_sec": src.get("cpu_sec"), "validity_gate_pass": src.get("validity_gate_pass"), "validity_ratio": src.get("validity_ratio", 1.0 if src.get("validity_gate_pass") else 0.0), "ratio_vs_li": 1.0}

def comp(cid, inc, wc, note):
    return {"id": cid, "incumbent": inc, "workload_class": wc, "executed": False, "cpu_sec": None, "validity_gate_pass": None, "validity_ratio": None, "ratio_vs_li": None, "note": note}

def comp_row(src, cid, inc, wc, note):
    li_sec = (src or {}).get("cpu_sec")
    csec = (src or {}).get("cpu_sec")
    ratio = None
    if li_sec and csec and li_sec > 0:
        ratio = round(csec / li_sec, 4)
    return {"id": cid, "incumbent": inc, "workload_class": wc, "executed": bool((src or {}).get("executed")), "cpu_sec": csec, "validity_gate_pass": (src or {}).get("validity_gate_pass"), "validity_ratio": (src or {}).get("validity_ratio"), "ratio_vs_li": ratio, "note": note, "numpy_version": (src or {}).get("numpy_version")}

matmul, mlp, async_env, llm, numpy_matmul = load("ph-ml-lkir-matmul.json"), load("ph-ml-mlp-forward.json"), load("ph-ml-async-env-collect.json"), load("ph-ml-llm-forward.json"), load("ph-ml-competitor-numpy-matmul.json")
rows = [
    {"id": "matmul_lkir", "kernel": "ml.lkir.matmul_f32", "workload_class": "pilot", "executed": bool(matmul.get("executed")), "li": li_row(matmul, "pilot"), "competitors": [comp("cpp_openmp", "C++/OpenMP matmul_blocked", "reference_native", "tier-2 cpp"), comp("rust_ndarray_rayon", "Rust/ndarray+rayon", "shared_c_kernel", "tier-2 rust"), comp_row(numpy_matmul, "python_numpy", "NumPy BLAS matmul", "blas_labeled", "numpy==pinned in driver")]},
    {"id": "mlp_forward", "kernel": "ml.mlp_forward_f32", "workload_class": "pilot", "executed": bool(mlp.get("executed")), "li": li_row(mlp, "pilot"), "competitors": [comp("cpp_openmp", "C++ MLP forward", "reference_native", "tier-1 catalog"), comp("python_numpy", "PyTorch nn.Linear", "blas_labeled", "incumbent ML")]},
    {"id": "async_env_collect", "kernel": "ml.rl.async_env_collect", "workload_class": "pilot", "executed": bool(async_env.get("executed")), "li": {**li_row(async_env, "pilot"), "worker": async_env.get("worker"), "worker_count": async_env.get("worker_count"), "parallelism_model": async_env.get("parallelism_model")}, "competitors": [comp("sb3_vecenv", "SB3 SubprocVecEnv", "stub", "documented pattern"), comp("ray_rllib", "Ray RLlib RolloutWorker", "stub", "documented pattern")]},
    {"id": "llm_forward", "kernel": "llm.forward_stub", "workload_class": "stub", "executed": bool(llm.get("executed")), "li": li_row(llm, "stub"), "competitors": [comp("llamacpp", "llama.cpp", "stub", "no weights parse"), comp("vllm", "vLLM", "stub", "GPU serving"), comp("pytorch_transformers", "transformers", "stub", "external TBD")]},
]
registry = os.environ["PH_ML_COMP_REGISTRY"]
out.write_text(json.dumps({"generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "suite": "ph-ml-competitive", "registry_path": registry, "registry_schema": "li_ph_ml_competitive_v1", "rows": rows}, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-competitive: done"
