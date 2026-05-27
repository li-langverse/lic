# Release notes: 2026-05-25 — lic-package-release-dispatch

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (branch `feat/lic-package-release-dispatch`)  
**PH / REQ:** WP3 benchmarks release manifest  
**Author:** agent

---

## Summary (one sentence)

Adds a tag `v*` GitHub Actions workflow that uploads `latest.csv`, sets `bench_required` from CSV presence, and dispatches `package-release` to `li-langverse/benchmarks`.

## Agent continuation (required)

1. Read: [benchmarks `release-manifest.md`](https://github.com/li-langverse/benchmarks/blob/main/docs/dashboard/release-manifest.md), `.github/workflows/benchmark-release.yml`
2. Run: after merge, ensure repo secret `LI_BENCHMARKS_DISPATCH_TOKEN`; smoke on next `v*` tag
3. Then: verify benchmarks ingest staged `data/incoming/manifests/lic-<version>.json` and `release-index.json` updated
4. Blocked on: benchmarks doc cross-link PR if not merged yet

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| CI | New `.github/workflows/benchmark-release.yml` on `push.tags: v*` | Reuses `ci.sh` / `ci-bench.sh` when `benchmarks/**` changed vs previous tag; always uploads `benchmark-csv` artifact |
| Dispatch | `package-release` → `li-langverse/benchmarks` with full `manifest` + `ref` | `bench_required` true iff `benchmarks/results/latest.csv` exists at tag |

## Not changed (scope fence)

- Weekly `benchmarks.yml` on `main`/`dev` and `lic-bench-complete` dispatch — unchanged
- `release.yml` tag creation logic — unchanged
- Benchmark ingest workflow in benchmarks repo — unchanged

## Breaking changes

None.

## Security

N/A — uses existing `LI_BENCHMARKS_DISPATCH_TOKEN`; no new secrets in repo.

## Performance

N/A — tag workflow runs tier-1 bench smoke only when `benchmarks/**` changed; otherwise reuses committed `latest.csv`.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Cross-link in `docs/dashboard/release-manifest.md` |

## CHANGELOG entry (paste into Unreleased)

- **Benchmark package-release:** tag `v*` workflow dispatches `package-release` to benchmarks with release manifest — `docs/release-notes/2026-05-25-lic-package-release-dispatch.md`.
