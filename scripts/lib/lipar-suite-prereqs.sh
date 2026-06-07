#!/usr/bin/env bash
# WP-PAR-02 — lic + li-httpd + tier5 oracle env for full lipar-suite / killer gate step 3.
set -euo pipefail

lipar_suite_ensure_prereqs() {
  local root="${1:?lic root}"
  export LIC_ROOT="$root"
  export LI_REPO_ROOT="$root"

  if [[ ! -x "$root/build/compiler/lic/lic" ]]; then
    echo "==> lipar-suite: building lic (missing build/compiler/lic/lic)"
    (cd "$root" && ./scripts/build.sh)
  fi
  export SKIP_BUILD="${SKIP_BUILD:-1}"

  if [[ ! -x "$root/build/li-httpd" ]]; then
    echo "==> lipar-suite: building li-httpd (tier5 exploit oracles)"
    (cd "$root" && ./scripts/build-li-httpd.sh)
  fi
  export LI_HTTPD_BIN="${LI_HTTPD_BIN:-$root/build/li-httpd}"

  # Full org suite runs tier5 exploits; apache/lighttpd are optional in agent runners.
  export TIER5_EXPLOIT_LANGS="${TIER5_EXPLOIT_LANGS:-nginx,li}"

  if ! command -v nginx >/dev/null 2>&1; then
    echo "lipar-suite: WARN nginx not in PATH — tier5 exploits may fail (install nginx)" >&2
  fi
}

# Shallow-cloned benchmarks often ship scripts without +x (WP-PAR-02 / killer gate step 3).
lipar_suite_ensure_bench_scripts() {
  local bench_root="${1:?benchmarks root}"
  if [[ ! -d "$bench_root/scripts" ]]; then
    return 0
  fi
  find "$bench_root/scripts" -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
}

# Tier-5 HTTP ingest can drop perf rows from latest.csv; tier-7 registry rebuilds breadth.
lipar_suite_refresh_registry() {
  local bench_root="${1:?benchmarks root}"
  local runs="${BENCH_RUNS:-3}"
  local runner="$bench_root/scripts/run-bench.sh"
  if [[ ! -x "$runner" ]]; then
    return 0
  fi
  export BENCHMARKS_ROOT="$bench_root"
  export BENCHMARKS_CSV="${BENCHMARKS_CSV:-$bench_root/results/latest.csv}"
  echo "==> lipar-suite: tier 7 registry refresh (runs=$runs)"
  bash "$runner" --tier 7 --runs "$runs" --skip-verify || {
    echo "lipar-suite: WARN tier 7 registry refresh failed" >&2
  }
}
