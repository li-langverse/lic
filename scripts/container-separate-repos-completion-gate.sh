#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase10-gate.sh"
echo "container-separate-repos completion gate: OK"
