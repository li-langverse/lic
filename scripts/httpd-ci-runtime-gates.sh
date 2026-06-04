#!/usr/bin/env bash
# PR CI slice: fast httpd runtime gates (subset of httpd-plan-gates.sh).
# Requires build/li-httpd; skips lic rebuild when HTTPD_GATES_SKIP_LIC_BUILD=1.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LIC="${LIC:-$ROOT/build/compiler/lic/lic}"

fail() { echo "httpd-ci-runtime-gates: $*" >&2; exit 1; }

if [[ "${HTTPD_CI_RUNTIME:-0}" != "1" ]]; then
  echo "httpd-ci-runtime-gates: skip (set HTTPD_CI_RUNTIME=1 to run)"
  exit 0
fi

if [[ "${HTTPD_GATES_SKIP_LIC_BUILD:-0}" != "1" ]]; then
  if [[ -x "$ROOT/scripts/build-li-httpd.sh" ]]; then
    echo "==> build-li-httpd.sh"
    "$ROOT/scripts/build-li-httpd.sh" || fail "build-li-httpd.sh failed"
  else
    fail "missing build-li-httpd.sh"
  fi
fi

[[ -x "$ROOT/build/li-httpd" ]] || fail "build/li-httpd missing"

export HTTPD_RUN_M2_TLS_H2_TEST=1
export HTTPD_RUN_M2_WEBSOCKET_TEST=1
export HTTPD_RUN_STICKY_LB_TEST=1
export HTTPD_RUN_LEAK_CENSOR_RUNTIME_TEST=0
export HTTPD_RUN_BEARER_TEST=0
export HTTPD_RUN_ACTIVE_HEALTH_TEST=0
export HTTPD_RUN_EXPLOIT_RUNTIME=0
export HTTPD_RUN_UPSTREAM_KEEPALIVE_TEST=0
export HTTPD_RUN_SERVE_PRODUCTION_TEST=0
export HTTPD_RUN_INFERENCE_LIVE_TEST=0
export HTTPD_RUN_SSE_RUNTIME_TEST=0
export HTTPD_RUN_M2_CIRCUIT_QUEUE_TEST=0
export HTTPD_RUN_M2_WEBHOOK_TEST=0
export HTTPD_RUN_M3_TOKEN_BUDGET_TEST=0
export HTTPD_RUN_STREAMING_SOAK_TEST=0
export HTTPD_RUN_PERF_REGRESSION_GATE=0
export HTTPD_RUN_PHASE2_GATES=0

for hook in \
  test-m2-tls-h2-runtime.sh \
  test-m2-websocket-runtime.sh \
  test-lb-sticky-sessions.sh \
  check-httpd-tls-dhe.sh; do
  if [[ -x "$ROOT/scripts/$hook" ]]; then
    echo "==> $hook"
    "$ROOT/scripts/$hook" || fail "$hook failed"
  else
    fail "missing $ROOT/scripts/$hook"
  fi
done

# test-m15-leak-censor-runtime.sh: httpd-plan-gates.sh only (egress CL/chunk framing).

echo "httpd-ci-runtime-gates: OK"
