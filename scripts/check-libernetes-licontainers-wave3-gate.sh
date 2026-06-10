#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/src/cri/serve.li"
test -f "$ROOT/packages/licontainers/src/runtime/cri_socket.li"
test -f "$ROOT/packages/licontainers/li-tests/integration/cri_socket_smoke.li"
echo "libernetes licontainers wave3 gate: OK"
