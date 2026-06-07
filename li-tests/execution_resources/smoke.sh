#!/usr/bin/env bash
# Execution resource controls: --cores/--threads-per-core team in LLVM IR;
# @vectorized builds must not reference li_parallel_for_i64.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
if [[ ! -x "$LIC" ]]; then
  echo "execution_resources/smoke: skip (no lic)" >&2
  exit 0
fi

fail() {
  echo "execution_resources/smoke: $*" >&2
  exit 1
}

NULL_OUT="/dev/null"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) NULL_OUT="NUL" ;;
esac

WORK="$ROOT/build/li-test-execution-resources-$$"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK"

PAR_LL="$WORK/parallel.ll"
VEC_LL="$WORK/vectorized.ll"
export LI_EMIT_LL="$PAR_LL"
"$LIC" build --release --cores=2 --threads-per-core=2 \
  "$ROOT/li-tests/execution_resources/parallel_disjoint_ok.li" -o "$NULL_OUT" >/dev/null
[[ -f "$PAR_LL" ]] || fail "missing parallel LLVM IR"
grep -q 'call.*li_parallel_for_i64' "$PAR_LL" || fail "parallel build should call li_parallel_for_i64"
grep -q 'i32 4' "$PAR_LL" || fail "expected team_size constant i32 4 in LLVM IR"

export LI_EMIT_LL="$VEC_LL"
"$LIC" build --release "$ROOT/li-tests/decorators/vectorized_for_scope_ok.li" -o "$NULL_OUT" >/dev/null
[[ -f "$VEC_LL" ]] || fail "missing vectorized LLVM IR"
if grep -q 'call.*li_parallel_for_i64' "$VEC_LL"; then
  fail "vectorized build must not call li_parallel_for_i64"
fi

warn="$(mktemp)"
"$LIC" build --release --threads=3 --cores=2 "$ROOT/li-tests/execution_resources/parallel_disjoint_ok.li" \
  -o "$NULL_OUT" 2>"$warn" >/dev/null || fail "build with both flags failed"
grep -q 'wins over --cores' "$warn" || fail "expected --threads over --cores warning"

echo "execution_resources/smoke: ok"
