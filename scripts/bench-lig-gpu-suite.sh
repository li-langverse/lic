#!/usr/bin/env bash
# PH-HW / lig GPU suite snapshot.
# Enumerates the whole lig kernel catalog, records visible GPU hardware, and runs
# the Li checks that exist before LKIR -> CUDA/HIP/Metal emit lands.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
REGISTRY="${LIG_GPU_SUITE_REGISTRY:-$ROOT/benchmarks/competitive/lig-kernels.toml}"
OUT="${LIG_GPU_SUITE_OUT:-$ROOT/benchmarks/results/lig-gpu-suite-latest.json}"
mkdir -p "$(dirname "$OUT")"

export LIG_GPU_SUITE_ROOT="$ROOT"
export LIG_GPU_SUITE_LIC="$LIC"
export LIG_GPU_SUITE_REGISTRY="$REGISTRY"
export LIG_GPU_SUITE_OUT="$OUT"

python3 <<'PY'
from __future__ import annotations

import json
import os
import shutil
import subprocess
import time
import tomllib
from pathlib import Path


root = Path(os.environ["LIG_GPU_SUITE_ROOT"])
lic = Path(os.environ["LIG_GPU_SUITE_LIC"])
registry = Path(os.environ["LIG_GPU_SUITE_REGISTRY"])
out = Path(os.environ["LIG_GPU_SUITE_OUT"])


def run(cmd: list[str], *, timeout: int = 180, env: dict[str, str] | None = None) -> dict:
    def clean(text: str | None) -> str:
        return (text or "").replace(str(root), "<repo>")

    start = time.perf_counter()
    try:
        p = subprocess.run(
            cmd,
            cwd=root,
            capture_output=True,
            text=True,
            timeout=timeout,
            env=env,
        )
        return {
            "cmd": [clean(part) for part in cmd],
            "exit": p.returncode,
            "ok": p.returncode == 0,
            "elapsed_sec": round(time.perf_counter() - start, 6),
            "stdout_tail": clean(p.stdout)[-600:],
            "stderr_tail": clean(p.stderr)[-600:],
        }
    except FileNotFoundError as exc:
        return {
            "cmd": [clean(part) for part in cmd],
            "exit": 127,
            "ok": False,
            "elapsed_sec": round(time.perf_counter() - start, 6),
            "error": str(exc),
        }
    except subprocess.TimeoutExpired as exc:
        return {
            "cmd": [clean(part) for part in cmd],
            "exit": 124,
            "ok": False,
            "elapsed_sec": round(time.perf_counter() - start, 6),
            "error": "timeout",
            "stdout_tail": clean(exc.stdout)[-600:] if isinstance(exc.stdout, str) else "",
            "stderr_tail": clean(exc.stderr)[-600:] if isinstance(exc.stderr, str) else "",
        }


def nvidia_gpu() -> dict:
    smi = shutil.which("nvidia-smi")
    if not smi:
        return {"visible": False, "tool": "nvidia-smi", "reason": "not_found"}
    query = (
        "name,driver_version,memory.total,compute_cap,pci.bus_id,"
        "temperature.gpu,power.limit"
    )
    p = run(
        [
            smi,
            f"--query-gpu={query}",
            "--format=csv,noheader,nounits",
        ],
        timeout=20,
    )
    if not p["ok"]:
        return {"visible": False, "tool": "nvidia-smi", "query": p}
    line = (p["stdout_tail"].strip().splitlines() or [""])[-1]
    parts = [x.strip() for x in line.split(",")]
    keys = [
        "name",
        "driver_version",
        "memory_total_mib",
        "compute_capability",
        "pci_bus_id",
        "temperature_c",
        "power_limit_w",
    ]
    gpu = dict(zip(keys, parts, strict=False))
    gpu["visible"] = True
    gpu["tool"] = "nvidia-smi"
    try:
        gpu["memory_total_mib"] = int(float(gpu.get("memory_total_mib", "0")))
    except ValueError:
        pass
    return gpu


def load_registry() -> tuple[dict, list[dict]]:
    data = tomllib.loads(registry.read_text(encoding="utf-8"))
    kernels = data.get("kernel", [])
    if not isinstance(kernels, list):
        kernels = []
    return data.get("meta", {}), kernels


def kernel_status(kernel: dict, gpu: dict, pilot_run_ok: bool) -> dict:
    kid = kernel.get("id", "")
    cuda_cell = kernel.get("cuda", "")
    is_pilot = kid == "lig.kernel.matmul_f32"
    cuda_ready = cuda_cell not in ("", "N/A", None)
    if cuda_ready:
        status = "cuda_catalog_ready"
        reason = "catalog row advertises cuda path"
    elif is_pilot and pilot_run_ok:
        status = "li_smoke_binary_passed"
        reason = "Li smoke binary exits 0; no GPU kernel emitted or timed"
    else:
        status = "blocked_lkir_cuda_emit"
        reason = "catalog row is N/A until Li LKIR CUDA/HIP/Metal emit exists"
    return {
        "kernel_id": kid,
        "bench_name": kernel.get("bench_name", ""),
        "lkir": kernel.get("lkir", ""),
        "workload_class": kernel.get("workload_class", ""),
        "validity_ref": kernel.get("validity_ref", ""),
        "cuda_catalog": cuda_cell,
        "target_gpu": gpu.get("name") if gpu.get("visible") else None,
        "backend": "cuda",
        "gpu_execution_status": "not_run" if not cuda_ready else "not_available_in_harness",
        "status": status,
        "reason": reason,
    }


generated_at = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
meta, kernels = load_registry()
gpu = nvidia_gpu()
tools = {
    "nvidia_smi": shutil.which("nvidia-smi") or "",
    "nvcc": shutil.which("nvcc") or "",
    "vulkaninfo": shutil.which("vulkaninfo") or "",
    "rocm_smi": shutil.which("rocm-smi") or "",
}

checks: dict[str, dict] = {}
checks["lig_device_probe"] = run(
    [str(lic), "check", "packages/lig/li-tests/smoke/lig_device_probe.li"],
    timeout=120,
)
checks["lig_wgpu_smoke"] = run(
    [str(lic), "check", "packages/lig/li-tests/smoke/wgpu_smoke.li"],
    timeout=120,
)
(root / "build" / "bench").mkdir(parents=True, exist_ok=True)
checks["lig_kernel_matmul_parity_build"] = run(
    [
        str(lic),
        "build",
        "--allow-open-vc",
        "--no-lean-verify",
        "packages/lig/li-tests/smoke/kernel_matmul_parity.li",
        "-o",
        "build/bench/lig_kernel_matmul_parity_suite",
    ],
    timeout=180,
)
if checks["lig_kernel_matmul_parity_build"]["ok"]:
    checks["lig_kernel_matmul_parity_run"] = run(
        ["build/bench/lig_kernel_matmul_parity_suite"],
        timeout=60,
    )

legacy_parity = run(["bash", "scripts/bench-lig-kernel-parity.sh"], timeout=240)
checks["bench_lig_kernel_parity"] = legacy_parity

pilot_run_ok = bool(checks.get("lig_kernel_matmul_parity_run", {}).get("ok"))
rows = [kernel_status(k, gpu, pilot_run_ok) for k in kernels]
cuda_ready_count = sum(1 for r in rows if r["status"] == "cuda_catalog_ready")
stub_pass_count = sum(1 for r in rows if r["status"] == "li_smoke_binary_passed")
blocked_count = sum(1 for r in rows if r["status"] == "blocked_lkir_cuda_emit")
smoke_checks_ok = all(v.get("ok") for v in checks.values())

report = {
    "schema": "ph-hw/lig-gpu-suite/v1",
    "generated_at": generated_at,
    "registry": str(registry.relative_to(root)),
    "registry_meta": meta,
    "gpu": gpu,
    "tools": tools,
    "possible_now": {
        "hardware_visible": bool(gpu.get("visible")),
        "cuda_kernel_timing": False,
        "reason": "RTX GPU is visible, but Li LKIR -> CUDA kernel emit is not implemented in this repo yet.",
    },
    "verification_mode": {
        "strict_proof_certificate": False,
        "allow_open_vc": True,
        "lean_verify": "skipped",
        "reason": "kernel_matmul_parity is a PH-HW smoke while full G-gpu proof/codegen remains open",
    },
    "summary": {
        "kernel_count": len(rows),
        "cuda_catalog_ready_count": cuda_ready_count,
        "li_smoke_binary_passed_count": stub_pass_count,
        "blocked_lkir_cuda_emit_count": blocked_count,
        "smoke_checks_ok": smoke_checks_ok,
    },
    "ai_status": {
        "mlp_forward_gpu": "cataloged_blocked_on_lkir_cuda_emit",
        "deep_learning_training": "not_timed_no_autograd_or_tensor_training_stack",
        "rl_gpu_batching": "not_timed_env_pool_stub_only",
        "agent_ai": "studio_agent_chrome_and_mcp_stubs_not_model_inference",
    },
    "checks": checks,
    "kernels": rows,
}

out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(out)
print(json.dumps({"gpu": gpu, "summary": report["summary"]}, indent=2))
PY

echo "bench-lig-gpu-suite: wrote $OUT"
