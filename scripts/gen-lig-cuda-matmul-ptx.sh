#!/usr/bin/env bash
# Regenerate runtime/lig_cuda_matmul2_ptx.inc from runtime/kernels/lig_matmul2x2.cu
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CUDA_HOME="${CUDA_HOME:-/usr/lib/cuda}"
export PATH="$CUDA_HOME/bin:${PATH:-}"
SRC="$ROOT/runtime/kernels/lig_matmul2x2.cu"
OUT_INC="$ROOT/runtime/lig_cuda_matmul2_ptx.inc"
TMP="$(mktemp /tmp/lig_matmul2.XXXXXX.ptx)"
nvcc -ptx -arch=sm_86 "$SRC" -o "$TMP"
python3 - "$TMP" "$OUT_INC" <<'PY'
import sys
from pathlib import Path
ptx = Path(sys.argv[1]).read_text()
out = Path(sys.argv[2])
lines = ['static const char k_lig_matmul2x2_ptx[] =']
for line in ptx.splitlines():
    lines.append(f'  "{line}\\n"')
lines.append(";")
lines.append(f"static const unsigned int k_lig_matmul2x2_ptx_len = {len(ptx)};")
out.write_text("\n".join(lines) + "\n")
print(out, len(ptx))
PY
rm -f "$TMP"
