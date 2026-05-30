# GitHub Linguist — Li usage evidence (WP3)

Documents **current GitHub Search state** for extension `.li` and the **human-only** steps to reach Linguist's usage bar for **Li Langverse Li** (not other ecosystems that happen to use `.li`).

**Agents:** maintain this doc's *process* and audit snapshots in lic; **do not** claim the threshold is met until Julian records passing searches below.

## Current state (audit 2026-05-25)

| Metric | Query (copy to browser) | Result at audit | Notes |
|--------|-------------------------|-----------------|-------|
| Global `.li` (indexed, no forks) | [`extension:li NOT is:fork`](https://github.com/search?type=code&q=extension%3Ali+NOT+is%3Afork) | **~1220** files (top-of-results count) | **Not** sufficient alone for Li PR — mixed provenance |
| Org `li-langverse` | [`org:li-langverse extension:li NOT is:fork`](https://github.com/search?type=code&q=org%3Ali-langverse+extension%3Ali+NOT+is%3Afork) | **0** at audit time | Primary gap for org-led PR |
| Li syntax filter (illustrative) | [`extension:li "requires" NOT is:fork`](https://github.com/search?type=code&q=extension%3Ali+%22requires%22+NOT+is%3Afork) | Subset of global | Use in PR **after** bar met; proves contract syntax |

### Collision risk (`.li`)

The extension is **not** reserved for Li Langverse today. Indexed `.li` files may include:

- **LemonOS** and similar projects (interface / tooling paths under other orgs)
- Unclassified or misclassified blobs until Linguist lists Li
- Hobby one-off repos

Maintainers require **≥2000** indexed files per extension (multi-file-per-repo case) and a **reasonable spread** across unique `user/repo` pairs — see [Linguist usage requirements](https://github.com/github-linguist/linguist/blob/main/CONTRIBUTING.md#language-extension-and-filename-usage-requirements). If one user dominates, add `-user:…` filters in the PR and in weekly audits.

**Cannot merge** Li into Linguist until the bar is met **or** a maintainer documents an explicit exception in the PR thread.

## Goal

GitHub Search (and Linguist reviewers) must see **thousands** of public `.li` files that are unmistakably **Li** (`def`/`proc`, `requires`/`ensures`, `import`, `lic` toolchain layout), with **many repos** outside a single maintainer account.

## Step-by-step — Julian (human)

### 1. Make `li-langverse/lic` searchable

1. Repository **public** (already true for `lic`).
2. Ensure `.li` is **not** gitignored at repo root and in packages (`li-tests/`, `examples/`, `packages/*/src`, `packages/*/li-tests/`).
3. Push real sources regularly; avoid force-pushing away history search indexes rely on.
4. Optional: add a short `README` badge or docs link so clones mirror Li layout (`li.toml`, `packages/`).

### 2. Seed public org repos

For each mirror or package repo you want counted:

1. **Public** GitHub repo under `li-langverse` (or trusted community orgs).
2. Include **multiple** `.li` files per repo (tests + src), not a single stub file.
3. Use normal Li idioms (contracts, imports) so heuristic/classifier training matches [WP2 samples](../../contrib/linguist-samples/Li/).
4. Prefer **unique** `user/repo` pairs over one mega-repo with all bytes.

Suggested seed order:

| Priority | Repo / area | Action |
|----------|-------------|--------|
| P0 | `lic` | Already largest corpus; keep `main` green and indexed |
| P1 | Official package mirrors | `scripts/push-official-package-repo.sh` — `.li` in `src/` and `li-tests/` |
| P2 | `examples/` | Publish standalone example repos (e.g. tetris) if split from monorepo |
| P3 | Community | Encourage early adopters to publish MIT `.li` with `li.toml` |

**Do not** flood GitHub with duplicate empty files or license-incompatible copies — reviewers spot artificial inflation.

### 3. Weekly search cadence (evidence log)

Every **Monday** (or pre-PR), Julian runs and **saves URLs + screenshot or copied count** in a private log (issue, gist, or PR draft). Suggested queries:

```text
extension:li NOT is:fork
org:li-langverse extension:li NOT is:fork
extension:li "requires" NOT is:fork -user:li-langverse
extension:li "ensures" NOT is:fork
extension:li "import " NOT is:fork org:li-langverse
```

Record in a table:

| Week (ISO) | Global count | `org:li-langverse` count | Li-syntax subset | Notes |
|------------|-------------|--------------------------|------------------|-------|
| 2026-W21 | ~1220 | 0 | (fill) | Baseline audit |

When **global ≥2000** *and* **org slice shows hundreds+** with diverse repos, attach the same URLs to the Linguist PR body (G2 in [playbook](./github-linguist.md)).

### 4. PR body evidence (after bar met)

Paste into upstream PR (template bullets):

- Primary: `extension:li NOT is:fork` — state count and confirm manual spot-check of random repos.
- Li-specific: `extension:li "requires" NOT is:fork` (and/or `ensures`, `proc`).
- If needed: `-user:<your-account>` to show distribution beyond language owners.
- Link [SAMPLES_LICENSES.md](../../contrib/linguist-samples/SAMPLES_LICENSES.md) commit and grammar MIT license.

## What agents may do

- Update **audit table** in this file when given fresh search counts (no rounding up).
- Improve seeding **docs/scripts** in lic that help humans publish mirrors.
- Prepare WP6 patch bundle and playbook cross-links.

## What agents must not do

- Claim usage threshold is met without Julian's logged search evidence.
- Mass-create junk public repos or commit to `github-linguist/linguist`.
- Replace Julian as PR author on Linguist.

## Unblock Linguist PR

| Blocker | Owner | Resolution |
|---------|-------|------------|
| WP1 grammar URL placeholder | WP1 + Julian | Publish `li-grammar`; merge WP1 |
| WP2 samples not on `main` | WP2 PR | Merge `feat/linguist-wp2-samples` |
| Usage &lt; 2000 / thin distribution | Julian (WP3) | Seed repos + weekly log |
| Heuristic for `.li` ambiguity | WP6 + Julian | Apply [`heuristics-li.fragment.yml`](../../contrib/linguist-upstream/heuristics-li.fragment.yml) if maintainers request |

## Related

- [Playbook G0–G8](./github-linguist.md)
- [PATCH_INSTRUCTIONS.md](../../contrib/linguist-upstream/PATCH_INSTRUCTIONS.md)
