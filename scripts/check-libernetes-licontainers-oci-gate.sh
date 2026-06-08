#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/src/oci/spec.li"
test -f "$ROOT/packages/licontainers/src/cri/v1.li"
echo "libernetes licontainers oci gate: OK"
