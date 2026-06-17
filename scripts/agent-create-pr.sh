#!/usr/bin/env bash
# Reliable PR open for Cloud Agents — workaround for ManagePullRequest create_pr (#120).
#
# ManagePullRequest can return "head branch has no commits on the remote" even when
# `git ls-remote origin <branch>` shows the tip SHA. This script:
#   1. Resets stale Cloud Agent git url rewrites (reset-git-github-profile.sh)
#   2. Waits until origin/<branch> is visible (retry + ls-remote)
#   3. Opens the PR with `gh pr create` (same path as manual workaround in #120)
#
# Usage:
#   ./scripts/agent-create-pr.sh --title "fix: …" [--body "…" | --body-file path]
#   BRANCH=my-branch BASE=main ./scripts/agent-create-pr.sh --title "…"
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
WRAPPER="$ROOT/scripts/with-github-env.sh"
RESET="$ROOT/scripts/reset-git-github-profile.sh"

REPO="${REPO:-li-langverse/lic}"
BASE="${BASE:-main}"
BRANCH="${BRANCH:-}"
TITLE=""
BODY=""
BODY_FILE=""
DRY_RUN=0
MAX_ATTEMPTS="${LI_AGENT_PR_REMOTE_ATTEMPTS:-12}"
RETRY_SEC="${LI_AGENT_PR_REMOTE_RETRY_SEC:-5}"

usage() {
  cat <<'EOF'
Usage: agent-create-pr.sh --title TITLE [options]

Options:
  --branch BRANCH     Head branch (default: current branch)
  --base BASE         Base branch (default: main)
  --repo ORG/REPO     GitHub repo (default: li-langverse/lic)
  --body TEXT         PR body markdown
  --body-file PATH    PR body from file
  --dry-run           Print actions without gh/network
  -h, --help          Show this help

Env:
  LI_AGENT_PR_REMOTE_ATTEMPTS  ls-remote retries (default 12)
  LI_AGENT_PR_REMOTE_RETRY_SEC sleep between retries (default 5)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) BRANCH="$2"; shift 2 ;;
    --base) BASE="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --body) BODY="$2"; shift 2 ;;
    --body-file) BODY_FILE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "agent-create-pr: unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

cd "$ROOT"
if [[ -z "$BRANCH" ]]; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
fi
if [[ -z "$TITLE" ]]; then
  echo "agent-create-pr: --title is required" >&2
  exit 2
fi
if [[ -n "$BODY_FILE" ]]; then
  if [[ ! -f "$BODY_FILE" ]]; then
    echo "agent-create-pr: --body-file not found: $BODY_FILE" >&2
    exit 2
  fi
  BODY="$(cat "$BODY_FILE")"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  li_phase "dry-run agent-create-pr"
  echo "  repo=$REPO base=$BASE head=$BRANCH"
  echo "  title=$TITLE"
  echo "  would run: reset-git-github-profile.sh + ls-remote retry + gh pr create"
  li_ok "agent-create-pr (dry-run)"
  exit 0
fi

if [[ ! -x "$WRAPPER" ]]; then
  echo "agent-create-pr: missing $WRAPPER" >&2
  exit 1
fi

li_phase "reset git github profile"
chmod +x "$RESET"
"$RESET"

wait_for_remote_branch() {
  local attempt=1
  while (( attempt <= MAX_ATTEMPTS )); do
    if "$WRAPPER" git ls-remote --heads origin "$BRANCH" 2>/dev/null | grep -q .; then
      li_ok "origin/$BRANCH visible (attempt $attempt/$MAX_ATTEMPTS)"
      return 0
    fi
    li_phase "waiting for origin/$BRANCH ($attempt/$MAX_ATTEMPTS)"
    sleep "$RETRY_SEC"
    attempt=$((attempt + 1))
  done
  return 1
}

li_phase "verify remote branch origin/$BRANCH"
if ! wait_for_remote_branch; then
  echo "agent-create-pr: origin/$BRANCH not visible after ${MAX_ATTEMPTS} attempts" >&2
  echo "hint: git push -u origin $BRANCH first (see scripts/agent-push-github.sh)" >&2
  exit 1
fi

li_phase "check existing PR for $BRANCH"
if "$WRAPPER" gh pr view --repo "$REPO" --head "$BRANCH" --json url -q .url 2>/dev/null; then
  existing="$("$WRAPPER" gh pr view --repo "$REPO" --head "$BRANCH" --json url -q .url)"
  li_ok "PR already open: $existing"
  echo "$existing"
  exit 0
fi

li_phase "gh pr create ($REPO)"
gh_args=(
  pr create
  --repo "$REPO"
  --base "$BASE"
  --head "$BRANCH"
  --title "$TITLE"
)
if [[ -n "$BODY" ]]; then
  gh_args+=(--body "$BODY")
else
  gh_args+=(--fill)
fi

pr_out="$("$WRAPPER" gh "${gh_args[@]}")"
url="$(printf '%s\n' "$pr_out" | grep -Eo 'https://github.com/[^[:space:]]+' | head -1 || true)"
if [[ -z "$url" ]]; then
  url="$pr_out"
fi
li_ok "PR opened: $url"
echo "$url"
