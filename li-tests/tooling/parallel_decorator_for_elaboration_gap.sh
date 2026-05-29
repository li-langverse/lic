#!/usr/bin/env bash
# G-dec / 7d-b: @parallel on plain `for` does not elaborate to OmpParallelFor (unlike `parallel for`).
# Also: @parallel without disjoint= on `for` is not rejected (policy_module only checks ParallelFor).
# Passes while gaps are open; update when decorator-for lowers or policy rejects missing disjoint.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
DECOR_FOR="$ROOT/li-tests/decorators/parallel_decorator_on_for_serial.li"
NO_DISJOINT="$ROOT/li-tests/decorators/parallel_decorator_on_for_no_disjoint.li"
KEYWORD="$ROOT/li-tests/parallel_codegen/parallel_float_zero.li"
BIN_DECOR="$(mktemp -t li_par_decor_for.XXXXXX)"
BIN_KW="$(mktemp -t li_par_kw_for.XXXXXX)"
trap 'rm -f "$BIN_DECOR" "$BIN_KW"' EXIT

# Policy gap: @parallel on for without disjoint= must still typecheck today.
if ! "$LIC" check "$NO_DISJOINT" >/dev/null 2>&1; then
  echo "parallel_decorator_for_elaboration_gap: @parallel on for without disjoint rejected — policy closed; update script"
  exit 1
fi

"$LIC" build "$DECOR_FOR" -o "$BIN_DECOR"
"$LIC" build "$KEYWORD" -o "$BIN_KW"

if ! nm "$BIN_KW" | grep -q '__li_par_'; then
  echo "parallel_decorator_for_elaboration_gap: control sample missing __li_par_* worker"
  exit 1
fi
if nm "$BIN_DECOR" | grep -q '__li_par_'; then
  echo "parallel_decorator_for_elaboration_gap: @parallel+for now emits __li_par_* — gap closed; update script"
  exit 1
fi
if objdump -d "$BIN_DECOR" --disassemble=li_user_main 2>/dev/null | grep -q 'li_omp_parallel_for_i64'; then
  echo "parallel_decorator_for_elaboration_gap: li_user_main calls li_omp_parallel_for_i64 — gap closed"
  exit 1
fi
if ! objdump -d "$BIN_KW" --disassemble=li_user_main 2>/dev/null | grep -q 'li_omp_parallel_for_i64'; then
  echo "parallel_decorator_for_elaboration_gap: control sample missing omp call in li_user_main"
  exit 1
fi

echo "parallel_decorator_for_elaboration_gap: ok (documented G-dec decorator-for serial + policy stub)"
