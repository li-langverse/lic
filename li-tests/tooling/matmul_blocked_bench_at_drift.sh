#!/usr/bin/env bash
# P-linalg / G-math: tier-1 matmul_blocked bench must stay aligned with ArrayMatMul2DF64 `@` lowering.
# When emit.cpp wires use_blocked_512, the tier-1 bench should use `C = A @ B` (perf branch pattern).
# When blocked `@` is absent, manual blocked loops are an intentional bench↔codegen drift (no `@` witness path).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
BENCH="$ROOT/benchmarks/tier1_micro/matmul_blocked/li/main.li"
PROBE="$ROOT/li-tests/math_linalg/matmul_512x512_at_codegen.li"
EMIT="$ROOT/compiler/codegen/emit.cpp"
WITNESS_CPP="$ROOT/compiler/verify/vc_witness.cpp"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if grep -q 'witness_matmul' "$WITNESS_CPP" 2>/dev/null; then
  echo "FAIL: expected no witness_matmul* in vc_witness.cpp (P-linalg gap)" >&2
  exit 1
fi

blocked_at_wired=false
if grep -q 'use_blocked_512' "$EMIT" 2>/dev/null; then
  blocked_at_wired=true
fi

bench_at_count="$(grep -c '@' "$BENCH" 2>/dev/null || true)"

if [[ "$blocked_at_wired" == true ]]; then
  if [[ "$bench_at_count" -lt 1 ]]; then
    echo "FAIL: emit.cpp wires blocked 512×512 @ but tier-1 matmul_blocked bench has no @ operator" >&2
    exit 1
  fi
else
  if [[ "$bench_at_count" -gt 0 ]]; then
    echo "FAIL: blocked @ not wired in emit.cpp but matmul_blocked bench uses @ (unexpected)" >&2
    exit 1
  fi
fi

"$LIC" check "$PROBE"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
BIN="$TMP/matmul512"
"$LIC" build "$PROBE" -o "$BIN" --release >/dev/null 2>&1

main_insns="$(objdump -d "$BIN" 2>/dev/null | awk '/<main>:/{f=1;next} /^[0-9a-f]+ <[^>]+>:/{if(f) exit} f' | wc -l)"
if [[ "$main_insns" -lt 20 ]]; then
  echo "FAIL: 512×512 @ probe main DCE'd (${main_insns} insns; need volatile_sink)" >&2
  exit 1
fi

if [[ "$blocked_at_wired" == true ]]; then
  echo "PASS matmul_blocked_bench_at_drift: blocked @ wired; bench uses @; no witness (main=${main_insns}ins)"
else
  echo "PASS matmul_blocked_bench_at_drift: manual blocked bench (no @); IKJ @ probe; no witness (main=${main_insns}ins)"
fi
