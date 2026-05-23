#!/usr/bin/env bash
# Gate: tier-2 physics verify.py smokes (md_lennard_jones + heat_equation_2d + rigid_body_stack).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

export CC="${CC:-clang-22}"
export CXX="${CXX:-clang++-22}"
export LIC="${LIC:-$ROOT/build/compiler/lic/lic}"

if [[ ! -x "$LIC" ]]; then
  li_fail "missing lic — run ./scripts/build.sh"
  exit 1
fi

li_phase "tier-2 physics verify smokes (md + heat PDE)"
python3 "$ROOT/benchmarks/harness/verify.py"
li_ok "tier-2 physics verify smokes ok"
