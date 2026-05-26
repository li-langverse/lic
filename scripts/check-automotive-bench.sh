#!/usr/bin/env bash
# PH-SIM automotive — validate automotive workspace composable (workspace root).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
"$LIC" check packages/li-sim-automotive/li-tests/smoke/tick_stub.li
"$LIC" check packages/li-sim-automotive/li-tests/smoke/bicycle_kinematic.li
"$LIC" check packages/li-sim-automotive/src/lib.li
