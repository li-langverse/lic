#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/src/hypervisor/backend.li"
echo "libernetes livm hypervisor gate: OK"
