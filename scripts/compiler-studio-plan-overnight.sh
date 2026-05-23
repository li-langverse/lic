#!/usr/bin/env bash
# Alias: continuous plan loop (kept for docs/scripts that reference overnight).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "$ROOT/scripts/compiler-studio-plan-continuous.sh"
