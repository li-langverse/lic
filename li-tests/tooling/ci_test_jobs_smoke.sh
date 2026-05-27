#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../../scripts/lib/li-jobs.sh
source "$ROOT/scripts/lib/li-jobs.sh"
saved_ci="${CI:-}"
# GHA exports CI=true globally; non-CI default is jobs=1 only without CI.
unset CI
[[ "$(li_test_jobs)" == "1" ]]
export CI=true
[[ "$(li_test_jobs)" -ge 1 ]]
export LI_TEST_JOBS=2
[[ "$(li_test_jobs)" == "2" ]]
[[ "$(li_workspace_jobs)" == "2" ]]
[[ -n "$saved_ci" ]] && export CI="$saved_ci"
echo "ci_test_jobs_smoke: ok"
