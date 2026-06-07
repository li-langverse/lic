#!/usr/bin/env bash
# WP-PAR-79–86 — chip package probes + li-parallel hetero orchestration (CPU+GPU+TPU+ASIC).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
else
  LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
fi

if [[ ! -x "$LIC" ]]; then
  echo "li_hetero_gate_smoke: lic missing — run ./scripts/build.sh" >&2
  exit 1
fi

for smoke in \
  packages/li-gpu/li-tests/smoke/lig_device_probe.li \
  packages/li-tpu/li-tests/smoke/device_probe.li \
  packages/li-asic/li-tests/smoke/device_probe.li
do
  echo "==> hetero smoke: $smoke"
  "$LIC" check "$ROOT/$smoke"
done

echo "==> hetero smoke: runtime orchestration (li_hetero_smoke.c)"
CC="${CC:-clang-22}"
OUT="$ROOT/build/li_hetero_smoke"
RT="$ROOT/runtime"
mkdir -p "$(dirname "$OUT")"
"$CC" -std=c11 -O2 -Wall -Wextra -D_DEFAULT_SOURCE \
  -I"$RT" \
  "$RT/test/li_hetero_smoke.c" \
  "$RT/li_rt_hetero.c" \
  "$RT/li_rt.c" \
  -pthread -lm \
  -o "$OUT"
"$OUT"

echo "li_hetero_gate_smoke: ok (GPU+TPU+ASIC probes + hetero orchestration)"
