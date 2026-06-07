#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-parallel-decorator: lic not built" >&2; exit 1; }
DECOR="$ROOT/li-tests/decorators/parallel_with_disjoint.li"
out="$("$LIC" verify "$DECOR" 2>&1)"
echo "$out" | grep -q 'mir_parallel_disjoint=1'
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
"$LIC" build "$DECOR" -o "$tmp/par" --release >/dev/null
sym_check() {
  local sym='li_omp_parallel_for_i64'
  local nm_out
  if command -v llvm-nm >/dev/null 2>&1; then nm_out="$(llvm-nm "$tmp/par" 2>/dev/null || true)"
  elif command -v nm >/dev/null 2>&1; then nm_out="$(nm "$tmp/par" 2>/dev/null || true)"
  else echo "check-mir-parallel-decorator: skip OpenMP symbol check" >&2; return 0
  fi
  echo "$nm_out" | grep -q "$sym"
}
sym_check
"$ROOT/li-tests/run_all.sh" race_shared_memory >/dev/null
echo check-mir-parallel-decorator: ok
