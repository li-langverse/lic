# Release notes: 2026-05-25 — ci-lic-cache-wp-c

**Status:** Ready for review (CI fix follow-up)  
**Repo:** li-langverse/lic  
**PR:** (open on `feat/ci-lic-ci-cache-wp-c`)  
**PH / REQ:** org-hygiene plan WP-C1–C5  
**Author:** agent

---

## Summary (one sentence)

Linux `lic` CI consumes `ghcr.io/li-langverse/lic-ci:ubuntu24-llvm22`, caches `build/`, adds reusable `package-ci` for mirrors, aligns LLVM 22 across Ubuntu workflows, and enables GHA layer cache on lic-ci image publish.

## Agent continuation (required)

1. Read: `docs/plans/2026-05-25-org-hygiene-multi-agent-plan.md` WP-C6; `scripts/templates/github-repo/ci.yml`; this file.
2. Run: after merge, `cd lic && ./scripts/ensure-package-ci.sh`; fan out mirror PRs with `uses: li-langverse/lic/.github/workflows/package-ci.yml@main`; compare `gh run view` durations vs pre-change baseline in PR #NNN.
3. Then: WP-C6 package fleet adoption; WP-E2 fuzz cache extend if needed.
4. Blocked on: **none** for C1–C5; C6 blocked until this PR merges to `main`.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Main CI | `build-and-test` uses `container: ghcr.io/li-langverse/lic-ci:ubuntu24-llvm22`; dropped `ci-install-llvm.sh` apt step | `.github/workflows/ci.yml` |
| Cache | `actions/cache@v4` on `build/` (and job-specific prefixes for lean/bench/fuzz/memory/hpc/rng) | `rg actions/cache .github/workflows/` |
| Reusable workflow | New `package-ci.yml` (`workflow_call`) | `.github/workflows/package-ci.yml` |
| Package template | Mirrors call reusable workflow instead of inline apt LLVM | `scripts/templates/github-repo/ci.yml` |
| Guard | `ensure-package-ci.sh` requires `package-ci.yml` | `./scripts/ensure-package-ci.sh` exit 0 |
| LLVM 22 | Ubuntu jobs use image env (`clang-22`, `/usr/lib/llvm-22/...`); fuzz header comment fixed | workflows listed above |
| Docker publish | `cache-from`/`cache-to` `type=gha` on both image builds | `.github/workflows/publish-docker-ci-image.yml` |
| Docs | GHA cache key table | `docs/ecosystem/local-ci-docker-images.md` |
| CI fix | lip/lit via `actions/checkout` → `ecosystem/` (container cannot write parent of workspace); `git safe.directory`; repair `lean.yml` job schema | `.github/workflows/ci.yml`, `scripts/lib/ecosystem-siblings.sh` |

## Not changed (scope fence)

- **WP-C6** — no package mirror repo PRs; monorepo `packages/*/ci.yml` not rewritten (only template + guard).
- **Security workflows** — `cve-catalog.yml`, `rng-exploit` gates, `run_security.sh` semantics unchanged.
- **macOS / Windows** CI — still host LLVM install (no lic-ci container on those runners).
- **ccache** — not enabled in CMake; no `~/.ccache` cache.
- **devbox** — `scripts/setup-li-devbox.sh` still documents llvm-18 paths (separate hygiene).
- **li-cursor-agents / benchmarks** — no cross-repo edits in this PR.

## Breaking changes

None — workflow inputs for `package-ci` are optional with defaults; existing mirror inline CI keeps working until adopters switch.

## Security

N/A — no change to CVE catalog, fuzz gates, or `run_security.sh` invocation paths on gated jobs.

## Performance

Expected faster Linux CI on cache hit (skip cold apt LLVM + incremental Ninja in `build/`). Record before/after `build-and-test` job duration in PR body after first green + re-run.

## Downstream

| Repo | Action |
|------|--------|
| Official package mirrors (~15) | After merge: PR replacing inline CI with `uses: li-langverse/lic/.github/workflows/package-ci.yml@main` (WP-C6) |
| lip / lit / lis | N/A |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Changed
- **CI platform (WP-C1–C5):** Linux jobs use `ghcr.io/li-langverse/lic-ci:ubuntu24-llvm22`, `actions/cache@v4` on `build/`, reusable `package-ci.yml`, GHA cache on docker publish — [2026-05-25-ci-lic-cache-wp-c.md](docs/release-notes/2026-05-25-ci-lic-cache-wp-c.md).
```
