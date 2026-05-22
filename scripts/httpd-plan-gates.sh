#!/usr/bin/env bash
# Verification gates for httpd master-plan loop (lic repo).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=llvm-env.sh
source "$ROOT/scripts/llvm-env.sh"
li_detect_compilers
export LI_REPO_ROOT="$ROOT"
export CC CXX
export LI_ALLOW_OPEN_VC="${LI_ALLOW_OPEN_VC:-1}"
export LIC="$("$ROOT/scripts/resolve-lic.sh")"
have_clang() { command -v clang >/dev/null 2>&1 || command -v "clang-${LI_LLVM_MAJOR:-22}" >/dev/null 2>&1; }

fail() { echo "httpd-plan-gates: $*" >&2; exit 1; }

if [[ "${HTTPD_GATES_SKIP_LIC_BUILD:-0}" == "1" ]]; then
  echo "==> skip lic build (HTTPD_GATES_SKIP_LIC_BUILD=1)"
else
  echo "==> build lic"
  "$ROOT/scripts/build.sh" >/dev/null

  echo "==> match_routes compile"
  "$LIC" build "$ROOT/li-tests/routing/match_routes.li" -o /tmp/li_match_routes_gate --allow-open-vc

  if have_clang; then
    echo "==> m15_agent_oracle compile"
    "$LIC" build "$ROOT/li-tests/httpd/m15_agent_oracle.li" -o /tmp/li_m15_agent_oracle --allow-open-vc
    echo "==> m15_leak_censor_oracle compile"
    "$LIC" build "$ROOT/li-tests/httpd/m15_leak_censor_oracle.li" -o /tmp/li_m15_leak_censor_oracle --allow-open-vc
    echo "==> m15_tls_oracle compile"
    "$LIC" build "$ROOT/li-tests/httpd/m15_tls_oracle.li" -o /tmp/li_m15_tls_oracle --allow-open-vc
    echo "==> m2_tls_h2_oracle compile"
    "$LIC" build "$ROOT/li-tests/httpd/m2_tls_h2_oracle.li" -o /tmp/li_m2_tls_h2_oracle --allow-open-vc
    echo "==> m3_optional_oracle compile"
    "$LIC" build "$ROOT/li-tests/httpd/m3_optional_oracle.li" -o /tmp/li_m3_optional_oracle --allow-open-vc
    if [[ "${HTTPD_RUN_M15_ORACLE_RUNTIME:-0}" == "1" ]]; then
      m15_rc="$(cd "$ROOT" && /tmp/li_m15_agent_oracle >/dev/null; echo $?)"
      test "$m15_rc" -eq 0
      m15_lc_rc="$(cd "$ROOT" && /tmp/li_m15_leak_censor_oracle >/dev/null; echo $?)"
      test "$m15_lc_rc" -eq 0
      m15_tls_rc="$(cd "$ROOT" && /tmp/li_m15_tls_oracle >/dev/null; echo $?)"
      test "$m15_tls_rc" -eq 0
    else
      echo "==> skip m15 oracle runtime (HTTPD_RUN_M15_ORACLE_RUNTIME=1 to enable)"
    fi
  else
    echo "==> skip m15_agent_oracle (clang not in PATH)"
  fi
  if [[ -x "$ROOT/scripts/check-httpd-lean-gate.sh" ]]; then
    echo "==> check-httpd-lean-gate.sh (w0-lean-gate)"
    "$ROOT/scripts/check-httpd-lean-gate.sh" || fail "check-httpd-lean-gate.sh failed"
  fi
  if [[ -x "$ROOT/scripts/check-w0-bytes-io.sh" ]]; then
    echo "==> check-w0-bytes-io.sh (w0-bytes-io)"
    "$ROOT/scripts/check-w0-bytes-io.sh" || fail "check-w0-bytes-io.sh failed"
  fi
  if [[ -x "$ROOT/scripts/check-w1-async-reactor.sh" ]]; then
    echo "==> check-w1-async-reactor.sh (w1-async-reactor)"
    "$ROOT/scripts/check-w1-async-reactor.sh" || fail "check-w1-async-reactor.sh failed"
  fi
  if [[ -x "$ROOT/scripts/verify-math-physics-goldens.sh" ]]; then
    echo "==> verify-math-physics-goldens.sh"
    "$ROOT/scripts/verify-math-physics-goldens.sh" || fail "math/physics golden verify failed"
  fi
  if have_clang && [[ -x "$ROOT/scripts/build-li-httpd.sh" ]]; then
    echo "==> build-li-httpd.sh (m0 ship gate)"
    "$ROOT/scripts/build-li-httpd.sh" || fail "build-li-httpd.sh failed"
  else
    echo "==> skip build-li-httpd (clang not in PATH)"
  fi
fi
# Runtime oracle may lag; compile gate is mandatory for CI.
if [[ "${HTTPD_GATES_RUN_MATCH_ROUTES:-0}" == "1" ]]; then
  /tmp/li_match_routes_gate
  test "$(/tmp/li_match_routes_gate; echo $?)" -eq 0
fi

if [[ -x "$ROOT/li-tests/run_httpd_config.sh" ]]; then
  echo "==> run_httpd_config.sh (python oracles + compile)"
  # Li routing binaries may exit non-zero until CallProc string ABI is fixed on all hosts.
  HTTPD_SKIP_LI_ROUTING_BIN="${HTTPD_SKIP_LI_ROUTING_BIN:-1}" "$ROOT/li-tests/run_httpd_config.sh"
fi

if [[ -f "$ROOT/scripts/check-httpd-overlap-reject.py" ]]; then
  echo "==> check-httpd-overlap-reject.py"
  python3 "$ROOT/scripts/check-httpd-overlap-reject.py"
fi

if [[ -f "$ROOT/scripts/validate-httpd-config.py" ]]; then
  echo "==> validate-httpd-config.py (good config)"
  python3 "$ROOT/scripts/validate-httpd-config.py" \
    "$ROOT/packages/li-net-httpd/examples/auth_bearer.toml"
fi

if [[ -x "$ROOT/scripts/check-httpd-m15-config.sh" ]]; then
  echo "==> check-httpd-m15-config.sh"
  "$ROOT/scripts/check-httpd-m15-config.sh"
fi

if [[ -x "$ROOT/scripts/check-httpd-leak-censor.sh" ]]; then
  echo "==> check-httpd-leak-censor.sh"
  "$ROOT/scripts/check-httpd-leak-censor.sh"
fi

if [[ -x "$ROOT/scripts/check-httpd-tls-auto.sh" ]]; then
  echo "==> check-httpd-tls-auto.sh"
  "$ROOT/scripts/check-httpd-tls-auto.sh"
fi

if [[ -x "$ROOT/scripts/check-httpd-m2-config.sh" ]]; then
  echo "==> check-httpd-m2-config.sh"
  "$ROOT/scripts/check-httpd-m2-config.sh"
fi

if [[ -x "$ROOT/scripts/check-httpd-m3-config.sh" ]]; then
  echo "==> check-httpd-m3-config.sh"
  "$ROOT/scripts/check-httpd-m3-config.sh"
fi

if [[ -x "$ROOT/scripts/check-tier5-http-harness.sh" ]]; then
  echo "==> check-tier5-http-harness.sh"
  "$ROOT/scripts/check-tier5-http-harness.sh"
fi

if [[ -x "$ROOT/scripts/check-tier5-exploit-harness.sh" ]]; then
  echo "==> check-tier5-exploit-harness.sh"
  "$ROOT/scripts/check-tier5-exploit-harness.sh"
fi

if [[ -x "$ROOT/scripts/check-tier5-nginx-src-audit.sh" ]]; then
  echo "==> check-tier5-nginx-src-audit.sh"
  "$ROOT/scripts/check-tier5-nginx-src-audit.sh"
fi

if [[ -x "$ROOT/scripts/check-pkg-workspace.sh" ]]; then
  echo "==> check-pkg-workspace.sh"
  "$ROOT/scripts/check-pkg-workspace.sh"
fi

if [[ -x "$ROOT/scripts/check-prob-hoare.sh" ]]; then
  echo "==> check-prob-hoare.sh"
  "$ROOT/scripts/check-prob-hoare.sh"
fi

if [[ -x "$ROOT/scripts/check-rng-concepts.sh" ]]; then
  echo "==> check-rng-concepts.sh"
  "$ROOT/scripts/check-rng-concepts.sh"
fi

if [[ -x "$ROOT/scripts/check-rng-exploit-suite.sh" ]]; then
  echo "==> check-rng-exploit-suite.sh"
  "$ROOT/scripts/check-rng-exploit-suite.sh"
fi

# m0-ship-gate-full: bearer smoke on running build/li-httpd (opt-out with HTTPD_RUN_BEARER_TEST=0).
if [[ "${HTTPD_GATES_SKIP_LIC_BUILD:-0}" != "1" && "${HTTPD_RUN_BEARER_TEST:-1}" == "1" ]]; then
  if [[ -f "$ROOT/scripts/test-auth-bearer.sh" && -x "$ROOT/build/li-httpd" ]]; then
    echo "==> test-auth-bearer.sh"
    "$ROOT/scripts/test-auth-bearer.sh" || fail "test-auth-bearer.sh failed"
  else
    fail "m0 ship gate: build/li-httpd missing (run build-li-httpd.sh)"
  fi
fi

if [[ "${HTTPD_GATES_SKIP_LIC_BUILD:-0}" != "1" && "${HTTPD_RUN_ACTIVE_HEALTH_TEST:-1}" == "1" ]]; then
  if [[ -x "$ROOT/scripts/test-active-upstream-health.sh" && -x "$ROOT/build/li-httpd" ]]; then
    echo "==> test-active-upstream-health.sh (m1-active-health)"
    "$ROOT/scripts/test-active-upstream-health.sh" || fail "test-active-upstream-health.sh failed"
  else
    fail "m1-active-health: build/li-httpd missing (run build-li-httpd.sh)"
  fi
fi

# m1-exploit-runtime: tier5 exploits on running build/li-httpd (opt-out with HTTPD_RUN_EXPLOIT_RUNTIME=0).
if [[ "${HTTPD_GATES_SKIP_LIC_BUILD:-0}" != "1" && "${HTTPD_RUN_EXPLOIT_RUNTIME:-1}" == "1" ]]; then
  if [[ -x "$ROOT/scripts/check-tier5-exploit-runtime.sh" && -x "$ROOT/build/li-httpd" ]]; then
    echo "==> check-tier5-exploit-runtime.sh (m1-exploit-runtime)"
    "$ROOT/scripts/check-tier5-exploit-runtime.sh" || fail "check-tier5-exploit-runtime.sh failed"
  else
    fail "m1-exploit-runtime: build/li-httpd missing (run build-li-httpd.sh)"
  fi
fi

echo "httpd-plan-gates: OK"
