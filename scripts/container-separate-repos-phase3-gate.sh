#!/usr/bin/env bash
# Phase 3: Linux trusted runtime in li_rt_container.c.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase2-gate.sh"

grep -q 'container_unshare' "$ROOT/runtime/li_rt_container.c"
grep -q 'container_cgroup' "$ROOT/runtime/li_rt_container.c"
grep -q 'container_pivot_root' "$ROOT/runtime/li_rt_container.c"
grep -qi 'container' "$ROOT/docs/semantics/trusted.lean"

echo "container-separate-repos phase3 gate: OK"
