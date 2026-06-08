#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/li-tests/smoke/builds.li"
test -f "$ROOT/packages/licontainers/li-tests/manifest.toml"
test -f "$ROOT/packages/licontainers/src/runtime/linux_backend.li"
echo "libernetes licontainers wave1 gate: OK"
