#!/usr/bin/env bash
# WP-HW-10: HIP/ROCm timing probe (honest N/A without ROCm hardware).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -z "${ROCM_PATH:-}" && -z "${HIP_PATH:-}" ]]; then
  echo '{"hip_device_ok": false, "hip_timing_ns": "N/A", "gpu_timing_ns": "N/A", "note": "ROCM_PATH unset"}'
  exit 0
fi
if ! command -v rocminfo >/dev/null 2>&1; then
  echo '{"hip_device_ok": false, "hip_timing_ns": "N/A", "gpu_timing_ns": "N/A", "note": "rocminfo missing"}'
  exit 0
fi
# Device matmul not wired yet — report hardware present only.
echo '{"hip_device_ok": false, "hip_timing_ns": "N/A", "gpu_timing_ns": "N/A", "hip_hardware": true, "note": "ROCm detected; device kernel pending"}'
