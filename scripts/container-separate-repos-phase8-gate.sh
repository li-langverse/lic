#!/usr/bin/env bash
# Phase 8: product completion — real runtime lifecycle + lictl CLI.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase7-gate.sh"

grep -q 'def runtime_create' "$ROOT/packages/li-container-run/src/runtime.li"
grep -q 'def emit_error_json' "$ROOT/packages/li-container/src/runerr.li"
grep -q 'def bundle_read_config' "$ROOT/packages/li-container/src/bundle.li"
grep -q 'def state_exists' "$ROOT/packages/li-container/src/state.li"
grep -q 'def lictl_cmd_run' "$ROOT/packages/li-container-cli/src/cli.li"
grep -q 'name = "lictl"' "$ROOT/packages/li-container-cli/li.toml"
grep -q 'lirun_cmd_create' "$ROOT/packages/li-container-run/src/runtime.li"

echo "container-separate-repos phase8 gate: OK"
