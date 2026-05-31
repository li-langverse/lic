# fix(cloud-agent): reliable PR open after push (#120)

Cloud Agent **ManagePullRequest** (`create_pr`) can fail with *"head branch has no commits on the remote"* even when `git ls-remote origin <branch>` shows the tip SHA.

## Changes

- `scripts/reset-git-github-profile.sh` — remove stale Cloud Agent `url.*.insteadOf` x-access-token rewrites; re-run `gh auth setup-git`
- `scripts/agent-create-pr.sh` — wait for `origin/<branch>` via `git ls-remote` (retry), then `gh pr create`
- `scripts/agent-push-github.sh` — call reset before push
- `docs/ecosystem/cloud-agent-vm.md`, `.cursor/rules/li-pr-only.mdc` — document workaround
- `li-tests/tooling/agent_github_pr_smoke.sh` — CI smoke

## Agent usage

```bash
./scripts/agent-push-github.sh "feat(scope): summary"
./scripts/agent-create-pr.sh --title "feat(scope): summary" --body-file docs/release-notes/….md
```

Fixes https://github.com/li-langverse/lic/issues/120
