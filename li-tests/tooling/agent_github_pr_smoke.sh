#!/usr/bin/env bash
# Smoke: agent PR helpers (reset-git-github-profile, agent-create-pr dry-run).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
chmod +x "$ROOT/scripts/reset-git-github-profile.sh" \
  "$ROOT/scripts/agent-create-pr.sh"

"$ROOT/scripts/reset-git-github-profile.sh"

OUT="$("$ROOT/scripts/agent-create-pr.sh" \
  --dry-run \
  --branch smoke-branch \
  --title "chore: smoke" \
  --body "test")"
grep -q 'dry-run agent-create-pr' <<<"$OUT" || {
  echo "agent_github_pr_smoke: dry-run missing banner" >&2
  exit 1
}
grep -q 'smoke-branch' <<<"$OUT" || {
  echo "agent_github_pr_smoke: dry-run missing branch" >&2
  exit 1
}

python3 - "$ROOT/scripts/reset-git-github-profile.sh" <<'PY'
import pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text()
assert "x-access-token@github.com" in text
assert "insteadof" in text.lower()
assert "gh auth setup-git" in text
PY

echo "agent_github_pr_smoke: ok"
