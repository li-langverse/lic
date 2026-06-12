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
bash "$ROOT/scripts/bench-ph-ml-li-array-matmul.sh" || true
bash "$ROOT/scripts/bench-ph-ml-li-array-matmul-32.sh" || true
bash "$ROOT/scripts/bench-ph-ml-lkir-matmul-16.sh" || true
bash "$ROOT/scripts/bench-ph-ml-lkir-matmul-32.sh" || true
bash "$ROOT/scripts/bench-ph-ml-mlp-forward.sh"
bash "$ROOT/scripts/bench-ph-ml-mlp-train-step.sh"
bash "$ROOT/scripts/bench-ph-ml-mlp-train-competitive.sh" || true
bash "$ROOT/scripts/bench-ph-ml-async-env-collect.sh"
bash "$ROOT/scripts/bench-ph-ml-sb3-train-step.sh" || true
bash "$ROOT/scripts/bench-ph-ml-llm-forward.sh"
bash "$ROOT/scripts/bench-ph-ml-llm-logits-oracle.sh" || true
bash "$ROOT/scripts/bench-ph-ml-llm-transformer-multilayer-parity.sh" || true
bash "$ROOT/scripts/bench-ph-ml-competitor-llm-all.sh" || true
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
liarray_matmul = load("ph-ml-li-array-matmul.json")
liarray_matmul32 = load("ph-ml-li-array-matmul-32.json")
matmul32 = load("ph-ml-lkir-matmul-32.json")
mlp = load("ph-ml-mlp-forward.json")
train = load("ph-ml-mlp-train-step.json")
mlp_train = load("ph-ml-mlp-train-competitive.json")
async_env = load("ph-ml-async-env-collect.json")
llm = load("ph-ml-llm-forward.json")
llamacpp = load("ph-ml-competitor-llamacpp.json")
vllm = load("ph-ml-competitor-vllm.json")
transformers_llm = load("ph-ml-competitor-transformers.json")
multilayer = load("ph-ml-transformer-multilayer-parity.json")
li_matmul_sec = matmul32.get("cpu_sec") if matmul32.get("executed") else matmul.get("cpu_sec")
matmul_wc = "tier3_cpu" if matmul32.get("executed") and matmul32.get("validity_gate_pass") else "pilot"
mlp_wc = "tier3_cpu" if train.get("autograd_mode") in ("pilot_backward", "full_backward") and train.get("executed") else "pilot"
li_mlp_sec = mlp.get("cpu_sec")

numpy_m = load("ph-ml-competitor-numpy-matmul.json")
numpy_m32 = load("ph-ml-competitor-numpy-matmul-32.json")
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
sb3_train = load("ph-ml-sb3-train-step.json")
ray_rllib = load("ph-ml-competitor-ray-rllib.json")

rows = [
    {
        "id": "li_array_matmul_4x4",
        "kernel": "array.matmul",
        "workload_class": "tier3_cpu" if liarray_matmul.get("executed") and liarray_matmul.get("validity_gate_pass") else "pilot",
        "workload_note": "4x4 f32 matmul via ArrayDesc -> ml_tensor_matmul_64; run-only cpu_sec",
        "executed": bool(liarray_matmul.get("executed")),
        "li": li_row(liarray_matmul, "tier3_cpu" if liarray_matmul.get("executed") and liarray_matmul.get("validity_gate_pass") else "pilot"),
        "competitors": [
            comp_row(numpy_m, liarray_matmul.get("cpu_sec"), "python_numpy", "NumPy BLAS matmul 4x4", "blas_labeled", "same-size reference"),
        ],
    },
    {
        "id": "li_array_matmul_32x32",
        "kernel": "array.matmul",
        "workload_class": "tier3_cpu" if liarray_matmul32.get("executed") and liarray_matmul32.get("validity_gate_pass") else "pilot",
        "workload_note": "32x32 logical f32 via ArrayDesc -> ml_matmul_cpu_logical_32; run-only 50x mean",
        "executed": bool(liarray_matmul32.get("executed")),
        "li": li_row(
            liarray_matmul32,
            "tier3_cpu" if liarray_matmul32.get("executed") and liarray_matmul32.get("validity_gate_pass") else "pilot",
        ),
        "competitors": [
            comp_row(
                numpy_m32,
                liarray_matmul32.get("cpu_sec"),
                "python_numpy",
                "NumPy BLAS matmul 32x32",
                "blas_labeled",
                "same-size reference; 50-run mean",
            ),
        ],
    },
    {
        "id": "matmul_lkir",
        "kernel": "ml.lkir.matmul_f32",
        "workload_class": matmul_wc,
        "workload_note": "32x32 LKIR matmul (tier3) when matmul-32 bench executes; else 4x4 pilot",
        "executed": bool(matmul.get("executed") or matmul32.get("executed")),
        "li": li_row(matmul32 if matmul32.get("executed") else matmul, matmul_wc),
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
        "workload_class": mlp_wc,
        "workload_note": "2-2-1 f32 MLP forward; tier3 when pilot_backward train step executes",
        "executed": bool(mlp.get("executed")),
        "li": li_row(mlp, mlp_wc),
        "competitors": [
            comp_row(cpp_openmp_mlp, li_mlp_sec, "cpp_openmp", "C++ MLP forward", "reference_native", "Wave 10 C++ MLP"),
            comp_row(numpy_mlp, li_mlp_sec, "python_numpy", "NumPy manual MLP", "blas_labeled", "Wave 10 NumPy MLP"),
            comp_row(pytorch_cpu_mlp, li_mlp_sec, "pytorch_cpu", "PyTorch CPU MLP forward", "blas_labeled", "torch pinned"),
        ],
    },
    {
        "id": "mlp_train",
        "kernel": "ml.mlp_sgd_step_f32",
        "workload_class": "tier3_cpu" if mlp_train.get("executed") else "pilot",
        "workload_note": mlp_train.get("workload_note") or "50-step XOR SGD; Li runtime autograd vs PyTorch CPU",
        "executed": bool(mlp_train.get("executed")),
        "li": {
            **li_row(mlp_train.get("li") or mlp_train, "tier3_cpu" if mlp_train.get("executed") else "pilot"),
            "cpu_sec": mlp_train.get("li_cpu_sec") or (mlp_train.get("li") or {}).get("cpu_sec"),
        },
        "competitors": [
            comp_row(
                {
                    "cpu_sec": mlp_train.get("pytorch_cpu_sec"),
                    "executed": bool((mlp_train.get("competitors") or [{}])[0].get("executed")),
                    "validity_gate_pass": (mlp_train.get("competitors") or [{}])[0].get("validity_gate_pass"),
                },
                mlp_train.get("li_cpu_sec"),
                "pytorch_cpu",
                "PyTorch CPU SGD",
                "blas_labeled",
                "same XOR fixture; manual SGD step",
            ),
        ],
    },
    {
        "id": "async_env_collect",
        "kernel": "ml.rl.async_env_collect",
        "workload_class": "pilot",
        "workload_note": async_env.get("semantics_honesty_note") or "Li reward-shard stub x4; SB3 uses real CartPole-v1",
        "executed": bool(async_env.get("executed")),
        "li": {
            **li_row(async_env, "pilot" if async_env.get("executed") else "stub"),
            "workload": async_env.get("workload"),
            "worker": async_env.get("worker"),
            "worker_count": async_env.get("worker_count"),
            "worker_backend": async_env.get("worker_backend"),
            "parallelism_model": async_env.get("parallelism_model"),
            "env_semantics": async_env.get("env_semantics"),
            "semantics_honesty_note": async_env.get("semantics_honesty_note"),
        },
        "competitors": [
            comp_row(sb3_vecenv, (async_env.get("cpu_sec") or 0.001), "sb3_vecenv", "SB3 SubprocVecEnv", "stub", "Wave 10 when gymnasium installed"),
            comp_row(ray_rllib, None, "ray_rllib", "Ray RLlib RolloutWorker", "stub", "honest pattern stub"),
        ],
    },
    {
        "id": "sb3_train_step",
        "kernel": "ml.rl.sb3_ppo_train",
        "workload_class": "pilot",
        "workload_note": sb3_train.get("semantics_honesty_note") or "SB3 PPO.learn CartPole-v1; Li native row pending",
        "executed": bool(sb3_train.get("executed")),
        "li": comp_stub("li", "Li native RL train", "stub", "no native policy-training loop yet"),
        "competitors": [
            comp_row(sb3_train, None, "sb3_train_step", "SB3 PPO CPU", "pilot", sb3_train.get("note") or "when gymnasium+sb3 installed"),
        ],
    },
    {
        "id": "llm_forward",
        "kernel": "llm.forward_stub",
        "workload_class": llm.get("workload_class") or ("pilot" if llm.get("tensor_metadata_ok") else ("tier3_cpu" if llm.get("validity_gate_pass") else "stub")),
        "executed": bool(llm.get("executed")),
        "li": li_row(llm, llm.get("workload_class") or ("pilot" if llm.get("tensor_metadata_ok") else "stub")),
        "competitors": [
            comp_row(llamacpp, llm.get("cpu_sec"), "llamacpp", "llama.cpp", "reference_native", "when llama-cli installed"),
            comp_row(vllm, llm.get("cpu_sec"), "vllm", "vLLM", "gpu_labeled", "when vllm installed"),
            comp_row(transformers_llm, llm.get("cpu_sec"), "pytorch_transformers", "transformers", "blas_labeled", "when transformers installed"),
        ],
    },
    {
        "id": "llm_transformer_multilayer",
        "kernel": "llm.forward_multilayer_matmul",
        "workload_class": multilayer.get("workload_class") or ("tier3_cpu" if multilayer.get("validity_gate_pass") else "stub"),
        "workload_note": "2-layer transformer forward via ml_matmul_f32; Li vs Python reference parity",
        "executed": bool(multilayer.get("executed")),
        "li": {
            **li_row(multilayer, multilayer.get("workload_class") or "tier3_cpu"),
            "reference_top_id": multilayer.get("reference_top_id"),
            "li_top_id": multilayer.get("li_top_id"),
            "hf_executed": multilayer.get("hf_executed"),
        },
        "competitors": [
            comp_row(
                transformers_llm,
                None,
                "pytorch_transformers",
                "transformers tiny-GPT2 smoke",
                "blas_labeled",
                "HF shape smoke when transformers installed; not weight parity",
            ),
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
