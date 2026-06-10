#!/usr/bin/env bash
# PH-7e / G-math: HornerConstLoopF64 scalar FMA loop witness (lic#11 / horner_pure_li).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
MIRROR="$ROOT/li-tests/math_linalg/horner_pure_li_mirror.li"
EDGE64="$ROOT/li-tests/math_linalg/horner_trip_edges.li"
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
if ! grep -A20 'case MirOp::HornerConstLoopF64' "$EMIT" | grep -q 'emit_fma_f64'; then
  echo "FAIL: HornerConstLoopF64 should emit scalar FMA steps via emit_fma_f64" >&2
  exit 1
fi

for probe in "$MIRROR" "$EDGE64"; do
  "$LIC" check "$probe"
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

"$LIC" build "$MIRROR" -o "$TMP/horner_mirror" --release 2>/dev/null
USER_ASM="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/horner_mirror" 2>/dev/null))"
FMA_COUNT="$(grep -c vfmadd <<<"$USER_ASM" || true)"
if [[ "${FMA_COUNT:-0}" -lt 1 ]]; then
  echo "FAIL: horner_pure_li_mirror release build should emit vfmadd in li_user_main" >&2
  exit 1
fi

echo "PASS horner_mir_codegen_gap: HornerConstLoopF64 scalar FMA loop + trip-edge probes"
