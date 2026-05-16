#!/usr/bin/env bash
# CI entry: build lic, li-tests, tier-0 benchmarks (verify + stability).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export CC="${CC:-clang}"
export CXX="${CXX:-clang++}"

echo "==> agent-kit sync check"
chmod +x "$ROOT/scripts/check-agent-kit-sync.sh" 2>/dev/null || true
if [[ -x "$ROOT/scripts/check-agent-kit-sync.sh" ]]; then
  "$ROOT/scripts/check-agent-kit-sync.sh" || {
    echo "hint: run ../roadmap/scripts/install-agent-kit.sh from sibling roadmap checkout" >&2
    exit 1
  }
fi

echo "==> build"
"$ROOT/scripts/build.sh"

echo "==> stdlib coverage gate (100% when instrumented)"
chmod +x "$ROOT/scripts/check-stdlib-coverage.sh"
"$ROOT/scripts/check-stdlib-coverage.sh"

export LI_REPO_ROOT="$ROOT"
export LIC="$("$ROOT/scripts/resolve-lic.sh")"

echo "==> generate AutoVC (2e) for semantics"
"$LIC" build "$ROOT/li-tests/modules/greeter/greeter.li" -o /dev/null

if command -v lake >/dev/null 2>&1; then
  export LI_BUILD_VERIFY_LEAN=1
  echo "==> semantics (2f lake build + AutoVC)"
  (cd "$ROOT/docs/semantics" && lake build) || exit 1
fi

echo "==> CVE / security gates (all OS — see scripts/ci-security.sh)"
chmod +x "$ROOT/scripts/ci-security.sh"
"$ROOT/scripts/ci-security.sh"

echo "==> httpd config + routing (M1 prep)"
chmod +x "$ROOT/li-tests/run_httpd_config.sh"
"$ROOT/li-tests/run_httpd_config.sh"

echo "==> E2E li-tests (full manifest)"
"$ROOT/li-tests/run_all.sh"

echo "==> tier 0 physics (strict stability)"
python3 "$ROOT/benchmarks/harness/bench.py" --tier 0

echo "==> race_shared_memory (parallel exploit suite)"
"$ROOT/li-tests/run_all.sh" race_shared_memory

echo "==> math_syntax (2h %, //, **)"
"$ROOT/li-tests/run_all.sh" math_syntax

echo "==> math_linalg (2i @ dot)"
"$ROOT/li-tests/run_all.sh" math_linalg

echo "==> workspace build stub (8a)"
chmod +x "$ROOT/scripts/lic-workspace-build.sh"
"$ROOT/scripts/lic-workspace-build.sh" "$ROOT/packages/li.toml"

echo "==> lip/lit stubs (8b/8e)"
chmod +x "$ROOT/scripts/lip" "$ROOT/scripts/lit" "$ROOT/li-tests/tooling/lip_lit_smoke.sh"
"$ROOT/li-tests/tooling/lip_lit_smoke.sh"

echo "==> encapsulation (2g def/object/import)"
"$ROOT/li-tests/run_all.sh" encapsulation

echo "==> decorator_exploits + decorators (7d policy/parse)"
"$ROOT/li-tests/run_all.sh" decorator_exploits decorators

echo "==> stdlib coverage instrument (8e)"
chmod +x "$ROOT/scripts/check-stdlib-coverage.sh"
"$ROOT/scripts/check-stdlib-coverage.sh"

echo "==> doc provability claims"
chmod +x "$ROOT/scripts/check-doc-provability-claims.sh"
"$ROOT/scripts/check-doc-provability-claims.sh"

echo "==> lic verify smoke (2e VC summary + 2f lean stub)"
chmod +x "$ROOT/scripts/lean-verify-stub.sh" "$ROOT/li-tests/tooling/lic_verify_smoke.sh" \
  "$ROOT/li-tests/tooling/vc_emit_contracts.sh" "$ROOT/li-tests/tooling/contracts_verify_lean.sh"
export LI_REPO_ROOT="$ROOT"
"$ROOT/li-tests/tooling/lic_verify_smoke.sh"
"$ROOT/li-tests/tooling/vc_emit_contracts.sh"
"$ROOT/li-tests/tooling/contracts_verify_lean.sh"

echo "==> 8-sync toolchain check"
chmod +x "$ROOT/scripts/check-li-toolchain.sh"
"$ROOT/scripts/check-li-toolchain.sh"

echo "==> package scaffold smoke"
chmod +x "$ROOT/li-tests/tooling/li_new_package_smoke.sh"
"$ROOT/li-tests/tooling/li_new_package_smoke.sh"

echo "==> traceability (official packages)"
chmod +x "$ROOT/scripts/check-traceability.sh"
"$ROOT/scripts/check-traceability.sh"

echo "==> master plan monorepo v1 gates"
chmod +x "$ROOT/scripts/check-master-plan-gates.sh"
"$ROOT/scripts/check-master-plan-gates.sh"

echo "ci: ok"
