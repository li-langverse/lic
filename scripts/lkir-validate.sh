#!/usr/bin/env bash
# WP-HW-04/05: validate .lkir modules against pilot schemas.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LKIR_DIR="${1:-$ROOT/packages/lig/lkir}"
PROBE="$ROOT/runtime/lig_lkir_validate_probe.c"
cat >"$PROBE" <<'C'
#include "li_rt_lkir_parse.h"
#include <stdio.h>
int main(int argc, char** argv) {
  if (argc < 3) return 2;
  const int kind = argv[1][0] == 'm' && argv[1][1] == 'l' ? 2 : 1;
  const int r = li_rt_lkir_validate_file(argv[2], kind);
  if (r < 0) {
    fprintf(stderr, "io_error: %s\n", argv[2]);
    return 3;
  }
  if (r != 1) {
    fprintf(stderr, "invalid: %s\n", argv[2]);
    return 1;
  }
  printf("ok %s\n", argv[2]);
  return 0;
}
C
CC="${CC:-clang}"
"$CC" -O2 -x c "$PROBE" -x c "$ROOT/runtime/li_rt_lkir_parse.c" -I"$ROOT/runtime" -o /tmp/lkir_validate_probe
fail=0
/tmp/lkir_validate_probe matmul "$LKIR_DIR/matmul_f32.lkir" || fail=1
/tmp/lkir_validate_probe mlp "$LKIR_DIR/mlp_forward_f32.lkir" || fail=1
exit "$fail"
