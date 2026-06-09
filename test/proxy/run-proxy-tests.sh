#!/bin/sh
# Formal TLS proxy relay suite - C unit oracles + optional docker integration.
# Exit 1 on any failure.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

C_ONLY=0
INTEGRATION_ONLY=0
SKIP_DOCKER=0
for arg in "$@"; do
  case "$arg" in
    --c-only) C_ONLY=1 ;;
    --integration-only) INTEGRATION_ONLY=1 ;;
    --skip-docker) SKIP_DOCKER=1 ;;
  esac
done

if [ "${PROXY_SKIP_DOCKER:-0}" = 1 ]; then
  SKIP_DOCKER=1
fi

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

resolve_lic() {
  for cand in "$ROOT/build/compiler/lic/lic" "$ROOT/build-wsl/compiler/lic/lic" "$ROOT/build/lic" "$ROOT/lic"; do
    if [ -x "$cand" ]; then
      export LIC=$cand
      return 0
    fi
  done
  return 1
}

if [ "$INTEGRATION_ONLY" -eq 0 ]; then
  echo "=== proxy C unit oracles ==="
  if resolve_lic; then
    echo "LIC=$LIC"
  else
    echo "WARN: no lic binary - C tests may skip or fail"
  fi
  if sh test/proxy-relay/run-unit-tests.sh --c-only; then
    echo "PASS proxy_c_unit"
    pass=$((pass + 1))
  else
    echo "FAIL proxy_c_unit"
    fail=$((fail + 1))
  fi
fi

if [ "$C_ONLY" -eq 0 ] && [ "$SKIP_DOCKER" -eq 0 ]; then
  if command -v docker >/dev/null 2>&1; then
    echo "=== proxy docker integration (proxy-repro) ==="
    compose="docker compose -f test/proxy-repro/docker-compose.yml"
    if $compose build proxy backend 2>/dev/null && $compose up --abort-on-container-exit tester; then
      echo "PASS proxy-repro-docker"
      pass=$((pass + 1))
    else
      echo "FAIL proxy-repro-docker"
      fail=$((fail + 1))
    fi
    $compose down -v 2>/dev/null || true
  else
    echo "=== proxy host integration (PROXY_PORT) ==="
    export PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
    export PROXY_PORT="${PROXY_PORT:-18443}"
    run_one test_parallel_same_asset test/proxy-relay/test_parallel_same_asset.sh
    run_one test_parallel_multi_asset test/proxy-relay/test_parallel_multi_asset.sh
  fi
elif [ "$C_ONLY" -eq 0 ] && [ "$SKIP_DOCKER" -eq 1 ]; then
  echo "SKIP docker integration (PROXY_SKIP_DOCKER=1)"
fi

echo "RESULT proxy-suite: pass=${pass} fail=${fail}"
[ "$fail" -eq 0 ]
