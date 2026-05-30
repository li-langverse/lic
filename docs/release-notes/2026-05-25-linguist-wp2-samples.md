# Release notes: 2026-05-25 — linguist-wp2-samples

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (branch `feat/linguist-wp2-samples`)  
**PH / REQ:** N/A (ecosystem tooling / linguist classifier prep)  
**Author:** agent

---

## Summary (one sentence)

Stage ten representative `.li` files under `contrib/linguist-samples/Li/` with license manifest and copy instructions for a future GitHub Linguist `samples/Li/` PR (no linguist fork push from lic).

## Agent continuation (required)

1. Read: `contrib/linguist-samples/README.md`, `contrib/linguist-samples/SAMPLES_LICENSES.md`
2. Run: `wc -l contrib/linguist-samples/Li/*.li` (expect 10 files, ≥295 total lines)
3. Then: WP6 — `rsync` into Julian's linguist fork `samples/Li/`, `bundle exec rake samples`, open upstream linguist PR
4. Blocked on: human (Julian) for linguist fork PR; **none** for lic merge after review

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Staging | `contrib/linguist-samples/Li/` — 10 verbatim `.li` copies (contracts, math, collections, tetris example, studio smoke) | `wc -l contrib/linguist-samples/Li/*.li` |
| Docs | `contrib/linguist-samples/README.md` — WP6 `rsync` path, no tutorial-only rule | path |
| Licenses | `contrib/linguist-samples/SAMPLES_LICENSES.md` — MIT, commit `c8e4b41c`, source paths | path |

## Not changed (scope fence)

- **github-linguist/linguist** — no PR, no push from this repo
- **Li grammar / compiler** — samples are read-only copies
- **`.gitattributes` / linguist heuristics in lic** — not in this slice

## Breaking changes

None.

## Security

N/A — documentation and test-source copies only; no runtime or trusted-surface change.

## Performance

N/A — no benchmark or codegen impact.

## Downstream

| Repo | Action |
|------|--------|
| linguist (Julian fork) | WP6: copy `contrib/linguist-samples/Li/` → `samples/Li/` per README |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **Linguist WP2 samples (staging):** `contrib/linguist-samples/Li/` (10 `.li` files), license manifest, WP6 copy README — [2026-05-25-linguist-wp2-samples.md](docs/release-notes/2026-05-25-linguist-wp2-samples.md).
```
