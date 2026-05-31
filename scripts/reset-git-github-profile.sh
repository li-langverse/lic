#!/usr/bin/env bash
# Clear stale Cursor Cloud Agent git url.*.insteadOf rewrites that break push/PR tools.
# Cloud VMs inject url.https://x-access-token@github.com/.insteadof globally; when stale or
# conflicting with ../.env.github GH_TOKEN, git push and ManagePullRequest create_pr fail
# even though `git ls-remote origin <branch>` succeeds after a PAT-backed push.
#
# See: https://github.com/li-langverse/lic/issues/120
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WRAPPER="$ROOT/scripts/with-github-env.sh"

unset_stale_insteadof() {
  local scope="${1:-}"
  local cfg=(git config)
  [[ -n "$scope" ]] && cfg+=(--"$scope")
  # Portable loop (macOS /bin/bash 3.2 lacks mapfile).
  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    # Only remove GitHub x-access-token rewrites (Cloud Agent injection).
    if [[ "$key" == *"x-access-token@github.com"* ]] || [[ "$key" == *"x-access-token:"* ]]; then
      "${cfg[@]}" --unset-all "$key" 2>/dev/null || true
    fi
  done < <("${cfg[@]}" --get-regexp '^url\..*\.insteadof$' 2>/dev/null | awk '{print $1}' | sort -u || true)
}

unset_stale_insteadof global
if git rev-parse --git-dir &>/dev/null; then
  unset_stale_insteadof local
fi

# Re-bind git credentials to gh + ../.env.github PAT when available.
if [[ -x "$WRAPPER" ]] && command -v gh >/dev/null 2>&1; then
  "$WRAPPER" gh auth setup-git 2>/dev/null || true
fi
