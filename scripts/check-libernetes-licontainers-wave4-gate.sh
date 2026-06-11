#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/src/runtime/remote.li"
test -f "$ROOT/packages/licontainers/li-tests/integration/remote_cri.li"
echo "libernetes licontainers wave4 gate: OK"
