#!/usr/bin/env bash
# Push plan-loop package slices from lic cursor/* branches to official mirror repos.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> fetch lic cursor branches"
git fetch origin '+refs/heads/cursor/*:refs/remotes/origin/cursor/*' main

PUSH="$ROOT/scripts/push-plan-loop-mirror-branch.sh"
OPEN="${LI_MIRROR_OPEN_PR:-1}"
EXTRA=()
[[ "$OPEN" == "1" ]] && EXTRA+=(--open-pr)

run() {
  "$PUSH" "$@" "${EXTRA[@]}" || true
}

echo "==> studio-ui-ux-plan-loop → studio / ui / render / li-gui"
BR=cursor/studio-ui-ux-plan-loop
run --lic-branch "$BR" --package li-studio --mirror-repo studio --mirror-branch "$BR"
run --lic-branch "$BR" --package li-ui --mirror-repo ui --mirror-branch "$BR"
run --lic-branch "$BR" --package li-gui --mirror-repo li-gui --mirror-branch "$BR" --create-repo
run --lic-branch "$BR" --package li-render --mirror-repo render --mirror-branch "$BR"

echo "==> sim-algo-plan-loop → sim / sim.scientific"
BR=cursor/sim-algo-plan-loop
run --lic-branch "$BR" --package li-sim --mirror-repo sim --mirror-branch "$BR"
run --lic-branch "$BR" --package li-sim-scientific --mirror-repo sim.scientific --mirror-branch "$BR"

echo "==> httpd-plan-continue → li-httpd"
BR=cursor/httpd-plan-continue
run --lic-branch "$BR" --package li-net-httpd --mirror-repo li-httpd --mirror-branch "$BR"

echo "==> compiler-studio-plan-loop → studio / ui / li-gui / render / world"
BR=cursor/compiler-studio-plan-loop
run --lic-branch "$BR" --package li-studio --mirror-repo studio --mirror-branch "$BR"
run --lic-branch "$BR" --package li-ui --mirror-repo ui --mirror-branch "$BR"
run --lic-branch "$BR" --package li-gui --mirror-repo li-gui --mirror-branch "$BR" --create-repo
run --lic-branch "$BR" --package li-render --mirror-repo render --mirror-branch "$BR"
run --lic-branch "$BR" --package li-world --mirror-repo world --mirror-branch "$BR"

echo "==> done (li-math-numerics has no org mirror; stays on lic only)"
