#!/usr/bin/env bash
# WP-T10-02: stale conflicting PRs closed (sign-off or live gh check).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

SIGNOFF="$ROOT/data/proof-explorer-loop/wp-t10-stale-prs-closed.signoff"
if [[ -f "$SIGNOFF" ]]; then
  echo "wp-t10-02-stale-prs-closed: OK (sign-off present)"
  exit 0
fi

if ! command -v gh >/dev/null 2>&1 || [[ -z "${GH_TOKEN:-}" ]]; then
  echo "wp-t10-02: gh/GH_TOKEN unavailable; need sign-off or env" >&2
  exit 1
fi

fail=0
# lic stale phase PRs + proof-library #4
check_closed() {
  local repo="$1" num="$2"
  state="$(gh pr view "$num" --repo "$repo" --json state -q .state 2>/dev/null || echo MISSING)"
  if [[ "$state" == "OPEN" ]]; then
    echo "wp-t10-02: $repo#$num still OPEN" >&2
    fail=1
  fi
}

for n in 819 653 668 660 656 663 701 654; do
  check_closed "li-langverse/lic" "$n"
done
check_closed "li-langverse/proof-library" 4

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "wp-t10-02-stale-prs-closed: OK"
