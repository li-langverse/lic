#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/src/hypervisor/kvm.li"
test -f "$ROOT/docs/libernetes/multi-os-matrix.md"
test -f "$ROOT/packages/livm/li-tests/smoke/builds.li"
test -f "$ROOT/packages/livm/li-tests/manifest.toml"
echo "libernetes livm wave1 gate: OK"
