#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/check-libernetes-control-progress-gate.sh"
bash "$ROOT/scripts/check-libernetes-control-docs-gate.sh"
bash "$ROOT/scripts/check-libernetes-control-crd-gate.sh"
bash "$ROOT/scripts/check-libernetes-control-packages-gate.sh"
bash "$ROOT/scripts/check-libernetes-control-wave1-gate.sh"
bash "$ROOT/scripts/check-libernetes-control-wave2-gate.sh"
bash "$ROOT/scripts/check-libernetes-control-wave3-gate.sh"
bash "$ROOT/scripts/check-libernetes-control-wave4-gate.sh"
echo "libernetes control completion gate: OK"
