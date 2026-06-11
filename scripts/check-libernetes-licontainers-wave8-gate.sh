#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/src/volume/persist.li"
test -f "$ROOT/packages/licontainers/li-tests/integration/reboot_recovery.li"
echo "libernetes licontainers wave8 gate: OK"
