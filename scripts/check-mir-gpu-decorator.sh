#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-gpu-decorator: lic not built" >&2; exit 1; }
DECOR="$ROOT/li-tests/decorators/gpu_only_ok.li"
out="$("$LIC" verify "$DECOR" 2>&1)"
echo "$out" | grep -q 'mir_gpu_proc=1'
MULTI="$ROOT/li-tests/decorators/gpu_multi_device_ok.li"
multi_out="$("$LIC" verify "$MULTI" 2>&1)"
echo "$multi_out" | grep -q 'mir_gpu_proc=1'
echo "$multi_out" | grep -q 'mir_gpu_multi_device_proc=1'
"$ROOT/li-tests/run_all.sh" decorators >/dev/null
echo check-mir-gpu-decorator: ok
