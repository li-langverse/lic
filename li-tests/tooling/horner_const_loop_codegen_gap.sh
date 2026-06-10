#!/usr/bin/env bash
# PH-7e / G-math: horner_pure_li bench scale (5M, const x) lowers to HornerConstLoopF64 + FMA.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
PROBE="$ROOT/li-tests/math_linalg/horner_const_loop_codegen_probe.li"
LOWER="$ROOT/compiler/mir/lower.cpp"
EMIT="$ROOT/compiler/codegen/emit.cpp"
if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'MirOp::HornerConstLoopF64' "$LOWER"; then
  echo "FAIL: expected HornerConstLoopF64 lowering in lower.cpp" >&2
  exit 1
fi
if ! grep -q 'case MirOp::HornerConstLoopF64:' "$EMIT"; then
  echo "FAIL: expected HornerConstLoopF64 codegen in emit.cpp" >&2
  exit 1
fi

"$LIC" check "$PROBE"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
"$LIC" build "$PROBE" -o "$TMP/horner_const_probe" --release --no-lean-verify 2>/dev/null

MAIN_ASM="$(objdump -d "$TMP/horner_const_probe" 2>/dev/null | sed -n '/<main>:/,/^$/p' || true)"
MAIN_FMA="$(printf '%s\n' "$MAIN_ASM" | grep -c vfmadd || true)"
if [[ "${MAIN_FMA:-0}" -lt 8 ]]; then
  echo "FAIL: bench-scale horner main should emit vfmadd block (HornerConstLoopF64 chunk FMA)" >&2
  exit 1
fi

MAIN_LINES="$(printf '%s\n' "$MAIN_ASM" | wc -l | tr -d ' ')"
if [[ "${MAIN_LINES:-0}" -gt 200 ]]; then
  echo "FAIL: main too large (${MAIN_LINES} lines) — likely scalar 5M horner loop" >&2
  exit 1
fi

# 5_000_000 / 64 = 78_125 = 0x1312d — chunk outer trip for HornerConstLoopF64.
if ! printf '%s\n' "$MAIN_ASM" | grep -q '0x1312d'; then
  echo "FAIL: expected chunk outer trip 0x1312d (5M/64) in main — HornerConstLoopF64 not applied" >&2
  exit 1
fi

echo "PASS horner_const_loop_codegen_gap: HornerConstLoopF64 + FMA at horner_pure_li scale (main_fma=${MAIN_FMA}, main_lines=${MAIN_LINES})"
