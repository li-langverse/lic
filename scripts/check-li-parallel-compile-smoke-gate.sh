#!/usr/bin/env bash
# WP-PAR-07–09 — program-first compile smokes: team, cluster, distributed for, reduce, @offload, overlap comm.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel compile smoke gate"

missing=()
for specimen in \
  li-tests/parallel_codegen/par_sum_f64.li \
  li-tests/parallel_codegen/par_for_reduce_f64.li \
  li-tests/parallel_codegen/dpar_for_range.li
do
  [[ -f "$ROOT/$specimen" ]] || missing+=("$specimen (file)")
done

if [[ ${#missing[@]} -gt 0 ]]; then
  li_fail "missing specimens: ${missing[*]}"
  exit 1
fi

for smoke in \
  li-tests/tooling/li_par_reduce_codegen_smoke.sh \
  li-tests/tooling/li_par_for_reduce_codegen_smoke.sh \
  li-tests/tooling/li_dpar_for_codegen_smoke.sh
do
  chmod +x "$ROOT/$smoke"
  bash "$ROOT/$smoke"
done

li_fail "WP-PAR-07–09 pending — team()/cluster() blocks, embedded __li_exec_plan, @offload, overlap comm specimens"
exit 1
