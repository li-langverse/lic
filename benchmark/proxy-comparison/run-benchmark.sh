#!/usr/bin/env bash
# Benchmark li-httpd vs nginx/caddy/haproxy under identical GitLab-like workloads.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
LIC_ROOT="$(cd "$ROOT/../.." && pwd)"
COMPOSE="docker compose -f $ROOT/docker-compose.yml"
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
OUT_DIR="${BENCH_OUT_DIR:-$ROOT/results/$STAMP}"
mkdir -p "$OUT_DIR"

log() { echo "[bench] $*" | tee -a "$OUT_DIR/run.log"; }

# --- TLS certs (shared hostname) ---
bash "$ROOT/gen-certs.sh" "$ROOT/certs"

# --- Pre-pull images (WSL credsStore workaround) ---
if [ -f "$ROOT/pull-images.sh" ]; then
  bash "$ROOT/pull-images.sh" 2>&1 | tee -a "$OUT_DIR/run.log" || log "WARN: pull-images partial failure"
fi

# --- Proxy matrix: name profile host_port service ---
# li-httpd last — longest image build (compiles lic + li-httpd).
declare -a PROXY_NAMES=("nginx-proxy" "caddy-proxy" "haproxy-proxy" "li-httpd")
declare -a PROXY_PROFILES=("nginx-proxy" "caddy-proxy" "haproxy-proxy" "li-httpd")
declare -a PROXY_PORTS=("18444" "18445" "18446" "18443")
declare -a PROXY_SERVICES=("nginx-proxy" "caddy-proxy" "haproxy-proxy" "li-httpd")

GIT_SHA=$(cd "$LIC_ROOT" && git rev-parse --short HEAD 2>/dev/null || echo unknown)
GIT_BRANCH=$(cd "$LIC_ROOT" && git branch --show-current 2>/dev/null || echo unknown)
log "lic $GIT_BRANCH @ $GIT_SHA"
log "results -> $OUT_DIR"

# --- Backend (shared static origin) ---
log "building backend..."
$COMPOSE build backend
log "starting backend..."
$COMPOSE up -d backend
$COMPOSE exec -T backend wget -q -O /dev/null http://127.0.0.1:8080/users/sign_in

RESULTS_JSON="$OUT_DIR/results.jsonl"
META_JSON="$OUT_DIR/meta.json"
: > "$RESULTS_JSON"

python3 - "$META_JSON" "$GIT_SHA" "$GIT_BRANCH" "$STAMP" <<'PY'
import json, sys
path, sha, branch, stamp = sys.argv[1:5]
meta = {
    "timestamp_utc": stamp,
    "lic_git_sha": sha,
    "lic_git_branch": branch,
    "proxies": ["li-httpd", "nginx-proxy", "caddy-proxy", "haproxy-proxy"],
    "workloads": ["sequential_1p3mb", "parallel_18", "parallel_6_same", "mix_small_large"],
    "vhost": "gitlab.lilangverse.xyz",
}
with open(path, "w") as f:
    json.dump(meta, f, indent=2)
PY

run_proxy_bench() {
  local name="$1" profile="$2" port="$3" service="$4"
  log "=== proxy: $name (port $port) ==="
  if [ "$service" = "li-httpd" ] && docker image inspect proxy-repro-proxy:latest >/dev/null 2>&1; then
    log "li-httpd: using local proxy-repro-proxy:latest image"
  else
    $COMPOSE --profile "$profile" build "$service" 2>&1 | tee -a "$OUT_DIR/build-$name.log" || true
  fi
  $COMPOSE --profile "$profile" up -d "$service"
  local ok=0 i=0
  while [ "$i" -lt 90 ]; do
    if $COMPOSE ps "$service" 2>/dev/null | grep -qE '(healthy|running)'; then
      if curl -sk --http1.1 --resolve "gitlab.lilangverse.xyz:${port}:127.0.0.1" \
        -o /dev/null --max-time 5 "https://gitlab.lilangverse.xyz:${port}/users/sign_in" 2>/dev/null; then
        ok=1; break
      fi
    fi
    if curl -sk --http1.1 --resolve "gitlab.lilangverse.xyz:${port}:127.0.0.1" \
      -o /dev/null --max-time 5 "https://gitlab.lilangverse.xyz:${port}/users/sign_in" 2>/dev/null; then
      ok=1; break
    fi
    sleep 2
    i=$((i + 1))
  done
  if [ "$ok" -eq 0 ]; then
    log "WARN: $name not healthy — skipping"
    $COMPOSE --profile "$profile" logs "$service" >> "$OUT_DIR/run.log" 2>&1 || true
    $COMPOSE --profile "$profile" stop "$service" 2>/dev/null || true
    return 1
  fi
  export PROXY_HOST=127.0.0.1 PROXY_PORT="$port" PROXY_VHOST=gitlab.lilangverse.xyz
  # Resource sampling during parallel_18
  bash "$ROOT/sample-resources.sh" "$service" 20 0.25 > "$OUT_DIR/resources-$name.json" &
  local sampler_pid=$!
  bash "$ROOT/workloads.sh" all "$name" | tee "$OUT_DIR/workloads-$name.jsonl" >> "$RESULTS_JSON"
  wait "$sampler_pid" 2>/dev/null || true
  # Idle RSS after burst
  sleep 1
  bash "$ROOT/sample-resources.sh" "$service" 2 0.5 > "$OUT_DIR/resources-idle-$name.json" || true
  $COMPOSE --profile "$profile" stop "$service"
  log "done: $name"
}

for idx in "${!PROXY_NAMES[@]}"; do
  run_proxy_bench "${PROXY_NAMES[$idx]}" "${PROXY_PROFILES[$idx]}" \
    "${PROXY_PORTS[$idx]}" "${PROXY_SERVICES[$idx]}" || true
done

$COMPOSE stop backend 2>/dev/null || true

python3 "$ROOT/parse-results.py" "$OUT_DIR"
log "wrote $OUT_DIR/RESULTS.md"
cat "$OUT_DIR/RESULTS.md"
