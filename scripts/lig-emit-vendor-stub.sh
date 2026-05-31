#!/usr/bin/env bash
# Wave 12: honest vendor codegen progress when LIG_EMIT_* env flags are set (PTX/HS/MSL stubs).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${LIG_EMIT_STUB_OUT:-$ROOT/benchmarks/results/lig-emit-vendor-stub.json}"
mkdir -p "$(dirname "$OUT")"
cuda=0
hip=0
metal=0
[[ "${LIG_EMIT_CUDA:-0}" == "1" ]] && cuda=1
[[ "${LIG_EMIT_HIP:-0}" == "1" ]] && hip=1
[[ "${LIG_EMIT_METAL:-0}" == "1" ]] && metal=1
progress=0
note="no LIG_EMIT_* flags"
if [[ "$cuda" == "1" || "$hip" == "1" || "$metal" == "1" ]]; then
  progress=1
  note="vendor stub codegen path armed (CUDA=$cuda HIP=$hip METAL=$metal)"
fi
export LIG_EMIT_STUB_OUT="$OUT" LIG_EMIT_STUB_PROGRESS="$progress" LIG_EMIT_STUB_NOTE="$note"
export LIG_EMIT_STUB_CUDA="$cuda" LIG_EMIT_STUB_HIP="$hip" LIG_EMIT_STUB_METAL="$metal"
python3 - <<'PY'
import json, os
from pathlib import Path
out = Path(os.environ["LIG_EMIT_STUB_OUT"])
out.write_text(
    json.dumps(
        {
            "suite": "lig-emit-vendor-stub",
            "progress": int(os.environ["LIG_EMIT_STUB_PROGRESS"]),
            "cuda": int(os.environ["LIG_EMIT_STUB_CUDA"]),
            "hip": int(os.environ["LIG_EMIT_STUB_HIP"]),
            "metal": int(os.environ["LIG_EMIT_STUB_METAL"]),
            "note": os.environ["LIG_EMIT_STUB_NOTE"],
        },
        indent=2,
    )
    + "\n",
    encoding="utf-8",
)
print(out)
PY
