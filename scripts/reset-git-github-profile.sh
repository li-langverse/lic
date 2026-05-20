#!/usr/bin/env bash
# Clear Cloud Agent git URL rewrites (stale x-access-token) and bind gh to ../.env.github.
# Run before push when you see: Permission denied to cursor[bot] / 403 on git push.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WRAPPER="$ROOT/scripts/with-github-env.sh"
LI_GITCONFIG="${LI_GITCONFIG:-/tmp/li-gitconfig-lic}"

while IFS= read -r key _; do
  [[ -n "$key" ]] || continue
  git config --global --unset-all "$key" 2>/dev/null || true
done < <(git config --global --get-regexp '^url\.' 2>/dev/null || true)
git config --global --remove-section url 2>/dev/null || true

cat >"$LI_GITCONFIG" <<'EOF'
[credential "https://github.com"]
	helper = !/usr/local/bin/gh auth git-credential
[credential "https://gist.github.com"]
	helper = !/usr/local/bin/gh auth git-credential
EOF

export GIT_CONFIG_GLOBAL="$LI_GITCONFIG"
export GIT_CONFIG_SYSTEM=/dev/null

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

# Do not run `gh auth setup-git` — it re-injects cursor x-access-token url.insteadOf rules.
"$WRAPPER" gh auth status >/dev/null
echo "reset-git-github-profile: PAT via gh (GIT_CONFIG_GLOBAL=$LI_GITCONFIG; url.* bypassed)"
