#!/usr/bin/env bash
# Minimal LKIR/GPU compile driver — selects cuda | rocm | metal | wgpu from li.toml.
# SPIR-V/wgpu is one backend, not the sole GPU entry (see docs/compiler/gpu-backend-driver.md).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOML="${1:-$ROOT/packages/lig/examples/engine_lig.toml}"
if [[ ! -f "$TOML" ]]; then
  echo "lig-gpu-compile-driver: missing TOML: $TOML" >&2
  exit 1
fi
line="$(grep -E '^\s*backend\s*=' "$TOML" | head -1 || true)"
if [[ -z "$line" ]]; then
  echo "lig-gpu-compile-driver: no [engine.lig] backend= line in $TOML" >&2
  exit 1
fi
export LI_GPU_BACKEND="${LI_GPU_BACKEND:-$(echo "$line" | sed -E 's/.*=\s*"([^"]+)".*/\1/')}"
case "$LI_GPU_BACKEND" in
  cuda|rocm|hip|metal|webgpu|wgpu) ;;
  *)
    echo "lig-gpu-compile-driver: unsupported backend '$LI_GPU_BACKEND' (want cuda|rocm|metal|webgpu)" >&2
    exit 1
    ;;
esac
[[ "$LI_GPU_BACKEND" == "hip" ]] && LI_GPU_BACKEND=rocm
[[ "$LI_GPU_BACKEND" == "wgpu" ]] && LI_GPU_BACKEND=webgpu
export LI_GPU_BACKEND
echo "lig-gpu-compile-driver: LI_GPU_BACKEND=$LI_GPU_BACKEND (from $TOML)"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "lig-gpu-compile-driver: lic not built" >&2; exit 1; }
"$ROOT/scripts/check-mir-gpu-decorator.sh"
echo "lig-gpu-compile-driver: MIR decorator gate ok; LKIR vendor emit remains G-gpu (stub)"
