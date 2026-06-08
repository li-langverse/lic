#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/check-libernetes-livm-progress-gate.sh"
bash "$ROOT/scripts/check-libernetes-livm-scaffold-gate.sh"
bash "$ROOT/scripts/check-libernetes-livm-hypervisor-gate.sh"
bash "$ROOT/scripts/check-libernetes-livm-crd-gate.sh"
bash "$ROOT/scripts/check-libernetes-livm-wave1-gate.sh"
echo "libernetes livm completion gate: OK"
