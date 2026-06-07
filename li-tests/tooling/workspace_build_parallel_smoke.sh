#!/usr/bin/env bash
# 8p-b: workspace member builds honor LI_TEST_JOBS / li_workspace_jobs pool.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../../scripts/lib/li-jobs.sh
source "$ROOT/scripts/lib/li-jobs.sh"
LIC_BIN="${LIC:-}"
if [[ -z "$LIC_BIN" ]]; then
  LIC_BIN="$("$ROOT/scripts/resolve-lic.sh" 2>/dev/null)" || {
    echo "workspace_build_parallel_smoke: skip (no lic)" >&2
    exit 0
  }
fi
if [[ ! -x "$LIC_BIN" ]]; then
  echo "workspace_build_parallel_smoke: skip (no lic)" >&2
  exit 0
fi

saved_ci="${CI:-}"
unset CI
[[ "$(li_workspace_jobs)" == "1" ]]
export LI_TEST_JOBS=2
[[ "$(li_workspace_jobs)" == "2" ]]
[[ -n "$saved_ci" ]] && export CI="$saved_ci"

export LI_REPO_ROOT="$ROOT"
export LIC="$LIC_BIN"
chmod +x "$ROOT/scripts/lic-workspace-build.sh"
export LI_TEST_JOBS=2
"$ROOT/scripts/lic-workspace-build.sh" "$ROOT/packages/li.toml"
echo "workspace_build_parallel_smoke: ok"
