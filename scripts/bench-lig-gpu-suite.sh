#!/usr/bin/env bash
# WP-BENCH-ML-05/06: honest GPU suite JSON (no fake ns timings).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/bench-lig-kernel-parity.sh"
PARITY="$ROOT/benchmarks/results/lig-lkir-matmul.json"
OUT="$ROOT/benchmarks/results/lig-gpu-suite-honest.json"
TIER3_STUB="$ROOT/benchmarks/results/tier3-ml-ingest-stub.json"
export LIG_EMIT_CUDA="${LIG_EMIT_CUDA:-0}"
export LIG_EMIT_HIP="${LIG_EMIT_HIP:-0}"
export LIG_EMIT_METAL="${LIG_EMIT_METAL:-0}"
export LIG_VULKAN_LAVA="${LIG_VULKAN_LAVA:-0}"

# WP-HW-09: probe CUDA_HOME when unset (lab + CI recipe in docs/ci/cuda-gpu-smoke.md).
if [[ -z "${CUDA_HOME:-}" && -z "${CUDA_PATH:-}" ]]; then
  for candidate in /usr/local/cuda /usr/lib/cuda /opt/cuda; do
    if [[ -x "${candidate}/bin/nvcc" ]]; then
      export CUDA_HOME="$candidate"
      break
    fi
  done
fi

PROBE="$ROOT/scripts/cuda-home-probe.sh"
TIMING_PROBE="$ROOT/scripts/lig-cuda-timing-probe.sh"
METAL_TIMING_PROBE="$ROOT/scripts/lig-metal-timing-probe.sh"
HIP_TIMING_PROBE="$ROOT/scripts/lig-hip-timing-probe.sh"
ORACLE_MLP="$ROOT/benchmarks/tier3_ml/mlp_forward/oracle_mlp_forward.py"
export LIG_BENCH_TIMING_PROBE="$TIMING_PROBE"
export LIG_BENCH_METAL_TIMING_PROBE="$METAL_TIMING_PROBE"
export LIG_BENCH_HIP_TIMING_PROBE="$HIP_TIMING_PROBE"
export LIG_BENCH_ORACLE_MLP="$ORACLE_MLP"
python3 - "$PARITY" "$OUT" "$TIER3_STUB" "$PROBE" <<'PY'
import json, os, sys
from pathlib import Path

parity_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
tier3_path = Path(sys.argv[3])
probe_script = Path(sys.argv[4]) if len(sys.argv) > 4 else None
cuda_home_probe = {}
if probe_script and probe_script.is_file():
    import subprocess
    try:
        out = subprocess.run(
            ["bash", str(probe_script)],
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
            cwd=str(probe_script.resolve().parent.parent),
        )
        if out.returncode == 0 and out.stdout.strip():
            cuda_home_probe = json.loads(out.stdout)
    except (OSError, json.JSONDecodeError):
        cuda_home_probe = {"probe_error": "cuda-home-probe failed"}

def env_on(name: str) -> bool:
    v = os.environ.get(name, "")
    return v not in ("", "0")

cuda_emit = env_on("LIG_EMIT_CUDA")
hip_emit = env_on("LIG_EMIT_HIP")
metal_emit = env_on("LIG_EMIT_METAL")
vulkan_lava = env_on("LIG_VULKAN_LAVA")
import platform

report = {
    "status": "honest_stub",
    "wave": "4d",
    "host_os": platform.system(),
    "gpu_timing_ns": "N/A",
    "cuda_timing_ns": "N/A",
    "metal_timing_ns": "N/A",
    "hip_timing_ns": "N/A",
    "vulkan_dispatch": "spirv_validation_stub_ok",
    "spirv_validation": "header_smoke_extended",
    "cuda_emit_status": 1 if cuda_emit else "emit_off",
    "metal_emit_status": 1 if metal_emit else "emit_off",
    "hip_emit_status": 1 if hip_emit else "emit_off",
    "vulkan_lavapipe_hint": vulkan_lava,
    "note": (
        "No GPU ns timings. cuda/hip emit=1 is host CPU ref matmul when enabled; "
        "vulkan bid=5 returns stub_ok after SPIR-V header validation (WP-HW-07)."
    ),
}
if parity_path.is_file():
    report["parity"] = json.loads(parity_path.read_text())
    pr = report["parity"]
    if pr.get("validity_gate_pass"):
        report["host_validity_ratio"] = pr.get("validity_ratio", "N/A")

def nvidia_smi_visible() -> bool:
    import shutil
    if shutil.which("nvidia-smi") is None:
        return False
    import subprocess
    try:
        return subprocess.run(
            ["nvidia-smi", "-L"],
            capture_output=True,
            timeout=5,
            check=False,
        ).returncode == 0
    except OSError:
        return False

def cuda_home_resolved() -> tuple[bool, str]:
    home = os.environ.get("CUDA_HOME") or os.environ.get("CUDA_PATH") or ""
    if home:
        return True, home
    for candidate in ("/usr/local/cuda", "/usr/lib/cuda", "/opt/cuda"):
        if (Path(candidate) / "bin" / "nvcc").is_file():
            return True, candidate
    return False, "unset"

def nvcc_visible() -> bool:
    import shutil
    if shutil.which("nvcc") is not None:
        return True
    cuda_home_ok, cuda_home_path = cuda_home_resolved()
    if cuda_home_ok:
        candidate = Path(cuda_home_path) / "bin" / "nvcc"
        if candidate.is_file():
            return True
    return False

cuda_home_ok, cuda_home_path = cuda_home_resolved()
report["cuda_hardware"] = {
    "nvidia_smi": nvidia_smi_visible(),
    "cuda_home": cuda_home_ok,
    "cuda_home_path": cuda_home_path,
    "nvcc": nvcc_visible(),
}
if cuda_home_probe:
    report["cuda_home_probe"] = cuda_home_probe
    if cuda_home_probe.get("embedded_ptx_kernel_ids"):
        report["ptx_catalog_embedded"] = cuda_home_probe["embedded_ptx_kernel_ids"]
    if cuda_home_probe.get("blocked_ptx_kernel_ids"):
        report["ptx_catalog_blocked"] = cuda_home_probe["blocked_ptx_kernel_ids"]
if cuda_emit:
    report["cuda_cpu_ref"] = "2x2_host_reference_when_emit_on"
    if not report["cuda_hardware"]["nvcc"]:
        report["wp_hw_09"] = "blocked_ptx_nvcc_toolkit_missing"
        report["cuda_toolkit_doc"] = "docs/ci/cuda-toolkit-setup.md"
    elif not cuda_home_ok:
        report["wp_hw_09"] = "blocked_ptx_cuda_home_unset_nvcc_present"
    else:
        timing_probe = os.environ.get("LIG_BENCH_TIMING_PROBE", "")
        if timing_probe:
            import subprocess

            try:
                tp = subprocess.run(
                    ["bash", timing_probe],
                    capture_output=True,
                    text=True,
                    timeout=60,
                    check=False,
                    cwd=str(Path(timing_probe).resolve().parent.parent),
                )
                if tp.returncode == 0 and tp.stdout.strip():
                    td = json.loads(tp.stdout)
                    if td.get("cuda_device_ok"):
                        report["cuda_timing_ns"] = td["cuda_timing_ns"]
                        report["gpu_timing_ns"] = td["gpu_timing_ns"]
                        report["wp_hw_08"] = "device_matmul2x2_pilot"
                        report["wp_hw_09"] = "ptx_device_pilot"
                        report["status"] = "cuda_device_pilot"
                        report["note"] = (
                            "Honest 2x2 CUDA device timing via lig-cuda-timing-probe; "
                            "Vulkan compute pipeline still partial (WP-HW-07)."
                        )
            except (OSError, json.JSONDecodeError, ValueError):
                pass

if metal_emit and platform.system() == "Darwin":
    metal_probe = os.environ.get("LIG_BENCH_METAL_TIMING_PROBE", "")
    if metal_probe:
        import subprocess

        try:
            mp = subprocess.run(
                ["bash", metal_probe],
                capture_output=True,
                text=True,
                timeout=60,
                check=False,
                cwd=str(Path(metal_probe).resolve().parent.parent),
            )
            if mp.returncode == 0 and mp.stdout.strip():
                md = json.loads(mp.stdout)
                if md.get("metal_device_ok"):
                    report["metal_timing_ns"] = md["metal_timing_ns"]
                    report["gpu_timing_ns"] = md["gpu_timing_ns"]
                    report["wp_hw_11"] = "metal_matmul2x2_pilot"
                    report["status"] = "metal_device_pilot"
                    report["note"] = (
                        "Honest 2x2 Metal device timing on Apple Silicon (LIG_EMIT_METAL=1)."
                    )
        except (OSError, json.JSONDecodeError, ValueError):
            pass

out_path.write_text(json.dumps(report, indent=2) + "\n")
tier3 = {
    "status": "ingest_stub",
    "wave": "4d",
    "family": "ml",
    "gpu_timing_ns": report.get("gpu_timing_ns", "N/A"),
    "note": "Tier-3 dashboard ingest placeholder until real oracle CSV lands",
}
oracle_mlp = os.environ.get("LIG_BENCH_ORACLE_MLP", "")
if oracle_mlp and Path(oracle_mlp).is_file():
    import subprocess

    try:
        orc = subprocess.run(
            [sys.executable, oracle_mlp],
            capture_output=True,
            text=True,
            timeout=120,
            check=False,
            cwd=str(Path(oracle_mlp).resolve().parent),
        )
        tier3["oracle_mlp_forward"] = {
            "ok": orc.returncode == 0,
            "checksum": (orc.stdout or "").strip() if orc.returncode == 0 else None,
        }
        if orc.returncode == 0:
            tier3["status"] = "oracle_smoke_ok"
    except OSError:
        tier3["oracle_mlp_forward"] = {"ok": False, "error": "oracle run failed"}

hip_probe = os.environ.get("LIG_BENCH_HIP_TIMING_PROBE", "")
if hip_emit and hip_probe:
    import subprocess

    try:
        hp = subprocess.run(
            ["bash", hip_probe],
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
            cwd=str(Path(hip_probe).resolve().parent.parent),
        )
        if hp.returncode == 0 and hp.stdout.strip():
            report["hip_probe"] = json.loads(hp.stdout)
    except (OSError, json.JSONDecodeError):
        pass
tier3_path.write_text(json.dumps(tier3, indent=2) + "\n")
print(out_path)
print(tier3_path)
PY
