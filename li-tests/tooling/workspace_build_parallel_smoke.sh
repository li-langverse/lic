#!/usr/bin/env bash
# 8p-b: verify lic-workspace-build.sh honors LI_TEST_JOBS / li_workspace_jobs pool.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
# shellcheck source=../../scripts/lib/li-jobs.sh
source "$ROOT/scripts/lib/li-jobs.sh"
# shellcheck source=../../scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
LIC_BIN="${LIC:-}"
if [[ -z "$LIC_BIN" ]]; then
  LIC_BIN="$(li_pick_lic_bin "$ROOT" 2>/dev/null || true)"
fi
if [[ -z "$LIC_BIN" || ! -x "$LIC_BIN" ]]; then
  echo "workspace_build_parallel_smoke: skip (no lic)" >&2
  exit 0
fi
export LIC="$LIC_BIN"
fail() { echo "workspace_build_parallel_smoke: $*" >&2; exit 1; }

export LI_TEST_JOBS=2
[[ "$(li_workspace_jobs)" == "2" ]] || fail "li_workspace_jobs should mirror LI_TEST_JOBS=2"

chmod +x "$ROOT/scripts/lic-workspace-build.sh"
log="$(mktemp "${TMPDIR:-/tmp}/li-ws-parallel-smoke.XXXX")"
if ! LI_TEST_JOBS=2 "$ROOT/scripts/lic-workspace-build.sh" "$ROOT/packages/li.toml" >"$log" 2>&1; then
  cat "$log" >&2
  fail "lic-workspace-build.sh failed with LI_TEST_JOBS=2"
fi
grep -q 'parallel jobs=2' "$log" || fail "expected parallel jobs=2 log line"
grep -q 'lic-workspace-build: ok' "$log" || fail "expected ok footer"
rm -f "$log"
echo "workspace_build_parallel_smoke: ok"
