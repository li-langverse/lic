#!/usr/bin/env bash
# wave-a-7d: @vectorized on def elaborates to MirFn.vectorized_lanes (default 4).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "vectorized_def_mir_smoke: lic not built" >&2; exit 1; }
export LI_REPO_ROOT="$ROOT"
export LI_MIR_DECOR_FLAGS=1
out="$("$LIC" verify "$ROOT/li-tests/decorators/vectorized_dot_proc_ok.li" 2>&1)" || {
  echo "$out" >&2
  exit 1
}
echo "$out" | grep -q 'mir_decor fn=dot4 vectorized_lanes=4 no_vectorize=0' || {
  echo "vectorized_def_mir_smoke: missing dot4 mir_decor line" >&2
  echo "$out" >&2
  exit 1
}
echo "$out" | grep -q 'mir_decor fn=main vectorized_lanes=0 no_vectorize=0' || {
  echo "vectorized_def_mir_smoke: missing main mir_decor line" >&2
  echo "$out" >&2
  exit 1
}
echo "OK vectorized_def_mir_smoke"
