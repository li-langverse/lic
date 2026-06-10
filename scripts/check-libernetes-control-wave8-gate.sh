#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/scripts/libernetes-etcd-backup.sh"
test -f "$ROOT/packages/li-libernetes-kubelet/li-tests/integration/reboot_recovery.li"
echo "libernetes control wave8 gate: OK"
