#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/docs/libernetes/crd-workerprofile.yaml"
echo "libernetes control crd gate: OK"
