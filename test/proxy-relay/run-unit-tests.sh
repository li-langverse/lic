#!/bin/sh
# Master runner for TLS proxy relay tests (TDD order).
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
cd "$ROOT"
C_ONLY=0
INTEGRATION_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --c-only) C_ONLY=1 ;;
    --integration-only) INTEGRATION_ONLY=1 ;;
  esac
done

pass=0
fail=0
run_one() {
  name=$1
  script=$2
  if sh "$script"; then
    echo "PASS $name"
    pass=$((pass + 1))
  else
    echo "FAIL $name"
    fail=$((fail + 1))
  fi
}

if [ "$INTEGRATION_ONLY" -eq 0 ]; then
  LIC=${LIC:-./build/lic}
  if [ ! -x "$LIC" ]; then
    for cand in ./build/compiler/lic/lic ./build-wsl/compiler/lic/lic ./lic; do
      if [ -x "$cand" ]; then
        LIC=$cand
        break
      fi
    done
  fi
  if [ -x "$LIC" ]; then
    echo "=== build proxy_relay_oracle ==="
    "$LIC" build li-tests/httpd/proxy_relay_oracle.li -o /tmp/proxy_relay_oracle 2>/dev/null || true
    echo "=== build proxy_relay_native ==="
    "$LIC" build --allow-open-vc packages/li-net-httpd/src/proxy_relay_native.li -o /tmp/proxy_relay_native 2>/dev/null || true
  fi
  if [ -x /tmp/proxy_relay_native ]; then
    /tmp/proxy_relay_native || { echo "FAIL proxy_relay_native binary"; fail=$((fail + 1)); }
  fi
  if [ -x /tmp/proxy_relay_oracle ]; then
    /tmp/proxy_relay_oracle || { echo "FAIL proxy_relay_oracle binary"; fail=$((fail + 1)); }
  else
    echo "SKIP proxy_relay_oracle (no lic build)"
  fi
  run_one test_tls_wbio_drain test/proxy-relay/test_tls_wbio_drain.sh
  run_one test_final_chunk_tail test/proxy-relay/test_final_chunk_tail.sh
  run_one test_proxy_cl_accounting test/proxy-relay/test_proxy_cl_accounting.sh
  run_one test_proxy_upstream_hold test/proxy-relay/test_proxy_upstream_hold.sh
  run_one test_cl_cap_no_desync test/proxy-relay/test_cl_cap_no_desync.sh
fi

if [ "$C_ONLY" -eq 0 ]; then
  run_one test_parallel_fairness test/proxy-relay/test_parallel_fairness.sh
  run_one test_parallel_same_asset test/proxy-relay/test_parallel_same_asset.sh
  run_one test_parallel_multi_asset test/proxy-relay/test_parallel_multi_asset.sh
  run_one test_parallel_hammer_3x test/proxy-relay/test_parallel_hammer_3x.sh
fi

echo "RESULT unit-tests: pass=${pass} fail=${fail}"
[ "$fail" -eq 0 ]
