#!/usr/bin/env bash
# Clear Cloud Agent git URL rewrites (stale x-access-token) and bind gh to ../.env.github.
# Run before push when you see: Permission denied to cursor[bot] / 403 on git push.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WRAPPER="$ROOT/scripts/with-github-env.sh"

while IFS= read -r key _; do
  [[ -n "$key" ]] || continue
  git config --global --unset-all "$key" 2>/dev/null || true
done < <(git config --global --get-regexp '^url\.' 2>/dev/null || true)

if git -C "$ROOT" remote get-url origin &>/dev/null; then
  origin="$(git -C "$ROOT" remote get-url origin)"
  case "$origin" in
    *@github.com/*)
      clean="${origin#*@github.com/}"
      git -C "$ROOT" remote set-url origin "https://github.com/${clean}"
      ;;
    x-access-token@*|*x-access-token*)
      git -C "$ROOT" remote set-url origin "https://github.com/li-langverse/lic.git"
      ;;
  esac
fi

"$WRAPPER" gh auth setup-git
echo "reset-git-github-profile: gh git-credential active; url.*.insteadOf cleared"
