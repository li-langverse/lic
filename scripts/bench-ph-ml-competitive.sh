#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"

# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
REGISTRY="$BENCHMARKS_COMPETITIVE/ph-ml.toml"
OUT="$BENCHMARKS_RESULTS/ph-ml-competitive.json"
mkdir -p "$BENCHMARKS_RESULTS"
bash "$ROOT/scripts/bench-ph-ml-lkir-matmul.sh"
bash "$ROOT/scripts/bench-ph-ml-lkir-matmul-16.sh" || true
bash "$ROOT/scripts/bench-ph-ml-mlp-forward.sh"
bash "$ROOT/scripts/bench-ph-ml-async-env-collect.sh"
bash "$ROOT/scripts/bench-ph-ml-llm-forward.sh"
bash "$ROOT/scripts/bench-ph-ml-competitor-numpy-matmul.sh"
bash "$ROOT/scripts/bench-ph-ml-competitor-all.sh"
export PH_ML_COMP_ROOT="$ROOT" PH_ML_COMP_OUT="$OUT" PH_ML_COMP_REGISTRY="$REGISTRY"
python3 <<'PY'
import json, os, time
from pathlib import Path

out = Path(os.environ["PH_ML_COMP_OUT"])
results = Path(os.environ["BENCHMARKS_RESULTS"])


def load(name):
    p = results / name
    return json.loads(p.read_text()) if p.is_file() else {}


def li_row(src, wc):
    return {
        "id": "li",
        "incumbent": "Li native",
        "workload_class": wc,
        "executed": bool(src.get("executed")),
        "cpu_sec": src.get("cpu_sec"),
        "validity_gate_pass": src.get("validity_gate_pass"),
        "validity_ratio": src.get("validity_ratio", 1.0 if src.get("validity_gate_pass") else 0.0),
        "ratio_vs_li": 1.0,
        "workload": src.get("workload"),
    }


def comp_stub(cid, inc, wc, note):
    return {
        "id": cid,
        "incumbent": inc,
        "workload_class": wc,
        "executed": False,
        "cpu_sec": None,
        "validity_gate_pass": None,
        "validity_ratio": None,
        "ratio_vs_li": None,
        "note": note,
    }


def comp_row(src, li_sec, cid, inc, wc, note):
    csec = (src or {}).get("cpu_sec")
    ratio = None
    if li_sec and csec and li_sec > 0:
        ratio = round(csec / li_sec, 6)
    return {
        "id": cid,
        "incumbent": inc,
        "workload_class": wc,
        "executed": bool((src or {}).get("executed")),
        "cpu_sec": csec,
        "validity_gate_pass": (src or {}).get("validity_gate_pass"),
        "validity_ratio": (src or {}).get("validity_ratio"),
        "ratio_vs_li": ratio,
        "note": (src or {}).get("note") or note,
        "framework_version": (src or {}).get("framework_version"),
        "device": (src or {}).get("device"),
        "workload_size": (src or {}).get("workload_size"),
        "workload": (src or {}).get("workload"),
    }


matmul = load("ph-ml-lkir-matmul.json")
mlp = load("ph-ml-mlp-forward.json")
async_env = load("ph-ml-async-env-collect.json")
llm = load("ph-ml-llm-forward.json")
li_matmul_sec = matmul.get("cpu_sec")
li_mlp_sec = mlp.get("cpu_sec")

numpy_m = load("ph-ml-competitor-numpy-matmul.json")
cpp_openmp_m = load("ph-ml-competitor-cpp-openmp-matmul.json")
rust_ndarray_m = load("ph-ml-competitor-rust-ndarray-matmul.json")
pytorch_cpu_m = load("ph-ml-competitor-pytorch-cpu-matmul.json")
pytorch_cuda_m = load("ph-ml-competitor-pytorch-cuda-matmul.json")
jax_cpu_m = load("ph-ml-competitor-jax-cpu-matmul.json")
tf_cpu_m = load("ph-ml-competitor-tensorflow-cpu-matmul.json")

matmul16 = load("ph-ml-lkir-matmul-16.json")
rust_mlp = load("ph-ml-competitor-rust-mlp.json")
triton_m = load("ph-ml-competitor-triton-matmul.json")
pytorch_cpu_mlp = load("ph-ml-competitor-pytorch-cpu-mlp.json")
numpy_mlp = load("ph-ml-competitor-numpy-mlp.json")
cpp_openmp_mlp = load("ph-ml-competitor-cpp-openmp-mlp.json")
sb3_vecenv = load("ph-ml-competitor-sb3-vecenv.json")
ray_rllib = load("ph-ml-competitor-ray-rllib.json")

rows = [
    {
        "id": "matmul_lkir",
        "kernel": "ml.lkir.matmul_f32",
        "workload_class": "pilot",
        "workload_note": "Li row: LKIR lig kernel kid=1 validity gate; competitors: 4x4 f32 identity matmul (50 runs)",
        "executed": bool(matmul.get("executed")),
        "li": li_row(matmul, "pilot"),
        "competitors": [
            comp_row(cpp_openmp_m, li_matmul_sec, "cpp_openmp", "C++/OpenMP matmul_blocked", "reference_native", "Wave 9 OpenMP pilot"),
            comp_row(rust_ndarray_m, li_matmul_sec, "rust_ndarray_rayon", "Rust/ndarray+rayon", "shared_c_kernel", "Wave 9 rustc pilot"),
            comp_row(numpy_m, li_matmul_sec, "python_numpy", "NumPy BLAS matmul", "blas_labeled", "numpy pinned"),
            comp_row(pytorch_cpu_m, li_matmul_sec, "pytorch_cpu", "PyTorch CPU matmul", "blas_labeled", "torch pinned"),
            comp_row(pytorch_cuda_m, li_matmul_sec, "pytorch_cuda", "PyTorch CUDA matmul", "gpu_labeled", "optional GPU"),
            comp_row(jax_cpu_m, li_matmul_sec, "jax_cpu", "JAX CPU matmul", "blas_labeled", "jax pinned"),
            comp_row(tf_cpu_m, li_matmul_sec, "tensorflow_cpu", "TensorFlow CPU matmul", "blas_labeled", "optional heavy dep"),
            comp_row(triton_m, li_matmul_sec, "triton_cuda", "Triton CUDA matmul kernel", "gpu_labeled", "GPU-only"),
        ],
    },
    {
        "id": "mlp_forward",
        "kernel": "ml.mlp_forward_f32",
        "workload_class": "pilot",
        "workload_note": "2-2-1 f32 MLP forward (ml_mlp_forward.li smoke shape)",
        "executed": bool(mlp.get("executed")),
        "li": li_row(mlp, "pilot"),
        "competitors": [
            comp_row(cpp_openmp_mlp, li_mlp_sec, "cpp_openmp", "C++ MLP forward", "reference_native", "Wave 10 C++ MLP"),
            comp_row(numpy_mlp, li_mlp_sec, "python_numpy", "NumPy manual MLP", "blas_labeled", "Wave 10 NumPy MLP"),
            comp_row(pytorch_cpu_mlp, li_mlp_sec, "pytorch_cpu", "PyTorch CPU MLP forward", "blas_labeled", "torch pinned"),
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
            comp_row(sb3_vecenv, (async_env.get("cpu_sec") or 0.001), "sb3_vecenv", "SB3 SubprocVecEnv", "stub", "Wave 10 when gymnasium installed"),
            comp_row(ray_rllib, None, "ray_rllib", "Ray RLlib RolloutWorker", "stub", "honest pattern stub"),
        ],
    },
    {
        "id": "llm_forward",
        "kernel": "llm.forward_stub",
        "workload_class": llm.get("workload_class") or ("tier3_cpu" if llm.get("validity_gate_pass") else "stub"),
        "executed": bool(llm.get("executed")),
        "li": li_row(llm, "stub"),
        "competitors": [
            comp_stub("llamacpp", "llama.cpp", "stub", "no weights parse"),
            comp_stub("vllm", "vLLM", "stub", "GPU serving"),
            comp_stub("pytorch_transformers", "transformers", "stub", "external TBD"),
        ],
    },
]

registry = os.environ["PH_ML_COMP_REGISTRY"]
out.write_text(
    json.dumps(
        {
            "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "suite": "ph-ml-competitive",
            "registry_path": registry,
            "registry_schema": "li_ph_ml_competitive_v1",
            "rows": rows,
        },
        indent=2,
    )
    + "\n",
)
print(out)
PY
echo "bench-ph-ml-competitive: done"
