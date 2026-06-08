#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/docs/libernetes/crd-virtualmachine.yaml"
echo "libernetes livm crd gate: OK"
