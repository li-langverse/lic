#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/src/disk/qcow2.li"
test -f "$ROOT/packages/livm/src/cloudinit/cloudinit.li"
grep -qi 'windows' "$ROOT/docs/libernetes/multi-os-matrix.md"
test -f "$ROOT/packages/livm/src/hypervisor/kvm_probe.li"
echo "libernetes livm wave2 gate: OK"
