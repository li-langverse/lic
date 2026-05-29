#!/usr/bin/env bash
# WP-HW-09: CUDA_HOME / nvcc probe for honest bench JSON (no GPU timing in this script).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$ROOT" <<'PY'
import json, os, shutil, subprocess, sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

root = Path(sys.argv[1])


def env_set(name: str) -> bool:
    v = os.environ.get(name, "")
    return v not in ("", "0")


def cuda_home_resolved() -> tuple[bool, str]:
    home = os.environ.get("CUDA_HOME") or os.environ.get("CUDA_PATH") or ""
    if home:
        return True, home
    for candidate in ("/usr/local/cuda", "/usr/lib/cuda", "/opt/cuda"):
        if (Path(candidate) / "bin" / "nvcc").is_file():
            return True, candidate
    return False, ""


cuda_home = os.environ.get("CUDA_HOME", "")
cuda_path = os.environ.get("CUDA_PATH", "")
nvcc_path = shutil.which("nvcc") or ""
cuda_home_ok, cuda_home_path = cuda_home_resolved()
if not nvcc_path and cuda_home_ok:
    candidate = Path(cuda_home_path) / "bin" / "nvcc"
    if candidate.is_file():
        nvcc_path = str(candidate)

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

manifest = root / "runtime" / "lig-ptx-catalog.toml"
embedded_ids: list[str] = []
blocked_ids: list[str] = []
if manifest.is_file():
    data = tomllib.loads(manifest.read_text(encoding="utf-8"))
    embedded_ids = [r.get("kernel_id", "") for r in data.get("embedded", [])]
    blocked_ids = [r.get("kernel_id", "") for r in data.get("blocked", [])]

has_toolkit = env_set("CUDA_HOME") or env_set("CUDA_PATH") or cuda_home_ok or bool(nvcc_path)
ready_cpu_ref = has_toolkit and bool(nvcc_path)

if nvidia_smi and not has_toolkit:
    wp_hw_09 = "blocked_ptx_nvcc_cuda_home_unset"
elif ready_cpu_ref:
    wp_hw_09 = "ready_emit_cpu_ref"
elif has_toolkit:
    wp_hw_09 = "ready_emit_cpu_ref"
elif nvidia_smi:
    wp_hw_09 = "blocked_ptx_nvcc_cuda_home_unset"
else:
    wp_hw_09 = "no_hardware"

print(
    json.dumps(
        {
            "cuda_home_set": env_set("CUDA_HOME"),
            "cuda_path_set": env_set("CUDA_PATH"),
            "cuda_home": cuda_home or cuda_home_path or None,
            "cuda_path": cuda_path or None,
            "nvcc_on_path": bool(nvcc_path),
            "nvcc_path": nvcc_path or None,
            "nvcc_version": nvcc_version or None,
            "nvidia_smi": nvidia_smi,
            "embedded_ptx_count": len(embedded_ids),
            "embedded_ptx_kernel_ids": embedded_ids,
            "blocked_ptx_kernel_ids": blocked_ids,
            "device_timing_in_this_probe": False,
            "device_timing_probe": "scripts/lig-cuda-timing-probe.sh",
            "ready_emit_cpu_ref": ready_cpu_ref,
            "wp_hw_09": wp_hw_09,
        },
        indent=2,
    )
)
PY
