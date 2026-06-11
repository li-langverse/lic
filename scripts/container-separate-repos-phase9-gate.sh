#!/usr/bin/env bash
# Phase 9: busybox integration + lictl ps state listing.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase8-gate.sh"

test -f "$ROOT/scripts/test-lirun-integration.sh"
test -f "$ROOT/packages/li-container-run/li-tests/integration/busybox.li"
grep -q 'container_state_list_stdout_i' "$ROOT/std/runtime/seam.li"
grep -q 'container_state_list_stdout_i' "$ROOT/runtime/li_rt_container.c"
grep -q 'lirun_argv_container_id_idx' "$ROOT/packages/li-container-run/src/runtime.li"
grep -q 'container_state_list_stdout_i' "$ROOT/packages/li-container-cli/src/cli.li"

echo "container-separate-repos phase9 gate: OK"
