#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/src/hypervisor/lios_probe.li"
grep -qi 'lios' "$ROOT/docs/libernetes/multi-os-matrix.md"
grep -q 'backend_lios_tag' "$ROOT/packages/livm/src/hypervisor/backend.li"
test -f "$ROOT/packages/livm/li-tests/smoke/lios_probe_smoke.li"
echo "libernetes livm wave3 gate: OK"
