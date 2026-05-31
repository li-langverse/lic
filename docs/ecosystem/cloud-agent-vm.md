# Cloud Agent VM bootstrap (LLVM 22)

Fresh Cursor Cloud VMs must install **LLVM 22** (org pin) before `lic` builds. Older install scripts pinned **LLVM 18** and failed with `set -u` + wrong `LLVM_DIR` expansion.

## One-line install script (Cursor Cloud settings)

Point the environment **install script** at (org-wide pull + LLVM 22 + dashboard-next):

```bash
bash /agent/repos/benchmarks/scripts/cloud-agent-install.sh
```

Minimal **lic-only** bootstrap (no org `git pull`):

```bash
bash /agent/repos/lic/scripts/cloud-vm-bootstrap.sh
```

Do **not** use inline `cmake -DLLVM_DIR="$LLVM_DIR"` with a same-line `LLVM_DIR=…` prefix under `set -u` — bash expands `$LLVM_DIR` before the assignment and fails with *unbound variable*.

## What it does

1. Runs `scripts/ci-install-llvm.sh` (LLVM **22**, clang-22, lld-22, llvm-22-dev).
2. Sources `scripts/llvm-env.sh` and writes `~/.config/environment.d/99-li-cloud.conf`.
3. Runs `./scripts/build.sh` in `lic` (skip with `LI_CLOUD_SKIP_BUILD=1`).
4. Optional: `benchmarks/dashboard` `npm ci` (skip with `LI_CLOUD_SKIP_BENCHMARKS=1`).
5. `pip3 install pytest` when available.

## Verify

```bash
source ~/.config/environment.d/99-li-cloud.conf
clang-22 --version
/agent/repos/lic/build/compiler/lic/lic --version
```

## GitHub push and PR (Cloud Agent)

Cursor **ManagePullRequest** (`create_pr`) can falsely report *"head branch has no commits on the remote"* even when `git ls-remote origin <branch>` shows the tip SHA ([#120](https://github.com/li-langverse/lic/issues/120)).

**Use lic scripts instead of ManagePullRequest:**

```bash
# After gates pass — commit + push (clears stale url.*.insteadOf rewrites)
./scripts/agent-push-github.sh "feat(scope): summary"

# Open PR (waits for origin/<branch>, then gh pr create)
./scripts/agent-create-pr.sh --title "feat(scope): summary" --body-file docs/release-notes/….md
```

Manual reset when push/PR tools misbehave:

```bash
./scripts/reset-git-github-profile.sh
./scripts/with-github-env.sh gh auth setup-git
```

## Related

- [getting-started-tools.md](../guide/getting-started-tools.md) — LLVM 22 manual install
- [devbox-li-development.md](../guide/devbox-li-development.md) — long-lived dev machines
- `scripts/setup-li-devbox.sh` — sudo + Node for engine hosts
