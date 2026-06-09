#!/bin/sh
# Formal TLS proxy integration pyramid — C unit oracles + docker layers 2–5.
# Exit 1 on any failure.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

RUN_UNIT=0
RUN_REAL_SITE=0
RUN_NEXTJS=0
RUN_GITLAB=0
RUN_LB=0
RUN_REPRO=0
C_ONLY=0
INTEGRATION_ONLY=0
SKIP_DOCKER=0
RUN_ALL=0

for arg in "$@"; do
  case "$arg" in
    --unit|--c-only) RUN_UNIT=1 ;;
    --real-site) RUN_REAL_SITE=1 ;;
    --nextjs) RUN_NEXTJS=1 ;;
    --gitlab) RUN_GITLAB=1 ;;
    --lb) RUN_LB=1 ;;
    --repro) RUN_REPRO=1 ;;
    --all) RUN_ALL=1 ;;
    --integration-only) INTEGRATION_ONLY=1 ;;
    --skip-docker) SKIP_DOCKER=1 ;;
  esac
done

if [ "$RUN_ALL" -eq 1 ]; then
  RUN_UNIT=1
  RUN_REAL_SITE=1
  RUN_NEXTJS=1
  RUN_GITLAB=1
  RUN_LB=1
  RUN_REPRO=1
fi

# Default (no flags): C unit only — fast CI gate.
if [ "$RUN_UNIT" -eq 0 ] && [ "$RUN_REAL_SITE" -eq 0 ] && [ "$RUN_NEXTJS" -eq 0 ] \
  && [ "$RUN_GITLAB" -eq 0 ] && [ "$RUN_LB" -eq 0 ] && [ "$RUN_REPRO" -eq 0 ] \
  && [ "$INTEGRATION_ONLY" -eq 0 ]; then
  RUN_UNIT=1
fi

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

run_compose() {
  name=$1
  compose_file=$2
  service=$3
  compose="docker compose -f $compose_file"
  echo "=== $name ($compose_file) ==="
  if $compose build 2>/dev/null && $compose up --abort-on-container-exit "$service"; then
    echo "PASS $name"
    pass=$((pass + 1))
  else
    echo "FAIL $name"
    fail=$((fail + 1))
  fi
  $compose down -v 2>/dev/null || true
}

run_lb_policy() {
  policy=$1
  name="lb-e2e-${policy}"
  compose="docker compose -f test/proxy-repro/docker-compose.lb.yml"
  echo "=== $name (LB_POLICY=${policy}) ==="
  if LB_POLICY="$policy" $compose build 2>/dev/null \
    && LB_POLICY="$policy" $compose up --abort-on-container-exit lb-tester; then
    echo "PASS $name"
    pass=$((pass + 1))
  else
    echo "FAIL $name"
    fail=$((fail + 1))
  fi
  LB_POLICY="$policy" $compose down -v 2>/dev/null || true
}

# Layer 1: C unit oracles
if [ "$RUN_UNIT" -eq 1 ] && [ "$INTEGRATION_ONLY" -eq 0 ]; then
  echo "=== Layer 1: proxy C unit oracles ==="
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

if [ "$SKIP_DOCKER" -eq 1 ]; then
  echo "SKIP docker layers (PROXY_SKIP_DOCKER=1 or --skip-docker)"
else
  if ! command -v docker >/dev/null 2>&1; then
    echo "SKIP docker layers (docker not available)"
  else
    if [ "$RUN_REPRO" -eq 1 ]; then
      run_compose "proxy-repro-docker" "test/proxy-repro/docker-compose.yml" "tester"
    fi

    if [ "$RUN_REAL_SITE" -eq 1 ]; then
      echo "=== Layer 2: real website proxy ==="
      run_compose "real-site-parallel" "test/integration/real-sites/docker-compose.yml" "tester"
    fi

    if [ "$RUN_NEXTJS" -eq 1 ]; then
      echo "=== Layer 3: Next.js chunk proxy ==="
      run_compose "nextjs-chunks" "test/nextjs-proxy/docker-compose.yml" "tester"
    fi

    if [ "$RUN_GITLAB" -eq 1 ]; then
      echo "=== Layer 4: GitLab sign_in proxy ==="
      run_compose "gitlab-parallel" "test/gitlab-proxy/docker-compose.yml" "tester"
    fi

    if [ "$RUN_LB" -eq 1 ]; then
      echo "=== Layer 5: load balancer e2e ==="
      run_lb_policy round_robin
      run_lb_policy least_conn
      run_lb_policy ip_hash
    fi
  fi
fi

# Host integration fallback when docker skipped but integration requested
if [ "$INTEGRATION_ONLY" -eq 1 ] && [ "$SKIP_DOCKER" -eq 1 ]; then
  echo "=== proxy host integration (PROXY_PORT) ==="
  export PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
  export PROXY_PORT="${PROXY_PORT:-18443}"
  run_one test_parallel_same_asset test/proxy-relay/test_parallel_same_asset.sh
  run_one test_parallel_multi_asset test/proxy-relay/test_parallel_multi_asset.sh
fi

echo "RESULT proxy-suite: pass=${pass} fail=${fail}"
[ "$fail" -eq 0 ]
