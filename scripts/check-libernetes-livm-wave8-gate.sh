#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/src/disk/persist.li"
test -f "$ROOT/packages/livm/li-tests/integration/reboot_recovery.li"
echo "libernetes livm wave8 gate: OK"
