#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/check-libernetes-licontainers-progress-gate.sh"
bash "$ROOT/scripts/check-libernetes-licontainers-oci-gate.sh"
bash "$ROOT/scripts/check-libernetes-licontainers-scaffold-gate.sh"
bash "$ROOT/scripts/check-libernetes-licontainers-cri-gate.sh"
bash "$ROOT/scripts/check-libernetes-licontainers-wave1-gate.sh"
echo "libernetes licontainers completion gate: OK"
