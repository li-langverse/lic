#!/usr/bin/env bash
# PH-ROBO — validate robotics.toml composable oracle (workspace root).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
"$LIC" check packages/li-sim-robotics/li-tests/smoke/tick_stub.li
"$LIC" check packages/li-sim-robotics/src/lib.li
