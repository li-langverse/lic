#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/check-libernetes-platform-progress-gate.sh"
bash "$ROOT/scripts/check-libernetes-platform-package-gate.sh"
bash "$ROOT/scripts/check-libernetes-foundation-stubs-gate.sh"
bash "$ROOT/scripts/check-libernetes-platform-wave1-gate.sh"
echo "libernetes platform completion gate: OK"
