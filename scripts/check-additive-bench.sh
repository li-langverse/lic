#!/usr/bin/env bash
# PH-AM — validate additive slicer composable oracle (workspace root).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
"$LIC" check packages/li-sim-additive/li-tests/smoke/tick_stub.li
"$LIC" check packages/li-sim-additive/li-tests/smoke/slice_plan.li
"$LIC" check packages/li-sim-additive/src/lib.li
