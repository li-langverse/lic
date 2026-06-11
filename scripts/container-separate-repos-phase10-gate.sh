#!/usr/bin/env bash
# Phase 10: lictl pull from any OCI v2 registry (GHCR, redhat.io, private).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase9-gate.sh"

test -f "$ROOT/scripts/oci-pull-to-bundle.sh"
grep -q 'container_registry_pull_i' "$ROOT/runtime/li_rt_container.c"
grep -q 'container_registry_pull_i' "$ROOT/std/runtime/seam.li"
test -f "$ROOT/packages/li-container/src/registry.li"
grep -q 'lictl_cmd_pull' "$ROOT/packages/li-container-cli/src/cli.li"
grep -q 'lictl_cmd_run_image' "$ROOT/packages/li-container-cli/src/cli.li"
grep -q 'GHCR_TOKEN' "$ROOT/scripts/oci-pull-to-bundle.sh"

echo "container-separate-repos phase10 gate: OK"
