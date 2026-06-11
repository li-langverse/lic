#!/usr/bin/env bash
# PH-7d / G-dec: unified MIR lowering exit gate for sub-phases 7d-b–e.
# Cross-links G-par where @parallel(disjoint=...) Host lowering is exercised.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-decorator-lowering: lic not built" >&2; exit 1; }

chmod +x \
  "$ROOT/scripts/check-mir-parallel-decorator.sh" \
  "$ROOT/scripts/check-mir-parallel-portable-lowering.sh" \
  "$ROOT/scripts/check-mir-vectorized-decorator.sh" \
  "$ROOT/scripts/check-mir-gpu-decorator.sh"

# 7d-b: proc/loop elaboration → MirDecorator tags + verify telemetry
"$ROOT/scripts/check-mir-vectorized-decorator.sh"
"$ROOT/scripts/check-mir-gpu-decorator.sh"

# 7d-b/c: @cpu + @parallel(disjoint=...) → Host OmpParallelFor → li_parallel_for_i64 (G-par slice)
"$ROOT/scripts/check-mir-parallel-portable-lowering.sh"
"$ROOT/scripts/check-mir-parallel-decorator.sh"

cpu_out="$("$LIC" verify "$ROOT/li-tests/decorators/cpu_only_ok.li" 2>&1)"
echo "$cpu_out" | grep -q 'mir_cpu_def=1'

# 7d-e: policy exploits must fail compile (reserved names, typosquat, missing disjoint=)
"$ROOT/li-tests/run_all.sh" decorator_exploits >/dev/null

# 7d-d: std.execution.decorators policy surface still builds
"$ROOT/li-tests/run_all.sh" decorators >/dev/null

echo check-mir-decorator-lowering: ok
