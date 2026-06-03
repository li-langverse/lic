#!/usr/bin/env bash
# Cross-repo PH-DB verify wrapper (local/WSL). Invoked by ph-db-swarm-plan completion gate.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PH_DB_GATES_FULL="${PH_DB_GATES_FULL:-1}"
exec bash "$ROOT/scripts/ph-db-plan-gates.sh"
