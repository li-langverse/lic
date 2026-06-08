#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/src/oci/image.li"
test -f "$ROOT/packages/licontainers/src/runtime/create.li"
test -f "$ROOT/packages/licontainers/src/runtime/start.li"
test -f "$ROOT/packages/licontainers/li-tests/integration/cri_lifecycle.li"
echo "libernetes licontainers wave2 gate: OK"
