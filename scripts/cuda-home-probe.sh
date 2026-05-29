#!/usr/bin/env bash
# WP-HW-09: CUDA_HOME / nvcc probe for honest bench JSON (no GPU timing).
set -euo pipefail

python3 - <<'PY'
import json, os, shutil, subprocess

def env_set(name: str) -> bool:
    v = os.environ.get(name, "")
    return v not in ("", "0")

cuda_home = os.environ.get("CUDA_HOME", "")
cuda_path = os.environ.get("CUDA_PATH", "")
nvcc_path = shutil.which("nvcc") or ""
nvcc_version = ""
if nvcc_path:
    try:
        out = subprocess.run(
            [nvcc_path, "--version"],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
        nvcc_version = (out.stdout or out.stderr or "").splitlines()[0].strip()
    except OSError:
        nvcc_version = ""

nvidia_smi = False
if shutil.which("nvidia-smi"):
    try:
        nvidia_smi = (
            subprocess.run(
                ["nvidia-smi", "-L"],
                capture_output=True,
                timeout=5,
                check=False,
            ).returncode
            == 0
        )
    except OSError:
        nvidia_smi = False

print(
    json.dumps(
        {
            "cuda_home_set": env_set("CUDA_HOME"),
            "cuda_path_set": env_set("CUDA_PATH"),
            "cuda_home": cuda_home or None,
            "cuda_path": cuda_path or None,
            "nvcc_on_path": bool(nvcc_path),
            "nvcc_path": nvcc_path or None,
            "nvcc_version": nvcc_version or None,
            "nvidia_smi": nvidia_smi,
            "wp_hw_09": (
                "blocked_ptx_nvcc_cuda_home_unset"
                if nvidia_smi and not (env_set("CUDA_HOME") or env_set("CUDA_PATH"))
                else (
                    "ready_emit_cpu_ref"
                    if env_set("CUDA_HOME") or env_set("CUDA_PATH")
                    else "no_hardware"
                )
            ),
        },
        indent=2,
    )
)
PY
