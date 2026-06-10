#!/usr/bin/env bash
# Phase 0: trusted seam + stub C runtime + container_trusted tests + package scaffolds.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

grep -q 'container_unshare_i' "$ROOT/std/runtime/seam.li"
test -f "$ROOT/runtime/li_rt_container.c"
test -d "$ROOT/li-tests/container_trusted"
test -f "$ROOT/li-tests/container_trusted/seam_policy_ok.li"

for pkg in li-oci li-container li-container-run; do
  test -f "$ROOT/packages/$pkg/li.toml"
  test -f "$ROOT/packages/$pkg/src/lib.li"
  test -f "$ROOT/packages/$pkg/li-tests/smoke/builds.li"
done

grep -q 'li-oci' "$ROOT/packages/li.toml"
grep -q 'li-container' "$ROOT/packages/li.toml"
grep -q 'li-container-run' "$ROOT/packages/li.toml"

echo "container-separate-repos phase0 gate: OK"
