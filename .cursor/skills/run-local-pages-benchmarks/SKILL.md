---
name: run-local-pages-benchmarks
description: >-
  Refresh li-langverse GitHub Pages (benchmarks dashboard + roadmap development
  overview) without GitHub Actions — local ingest, relative cpp ratios, hardware
  banner, gh-pages deploy. Use when live sites are stale, GHA quota is exhausted,
  or the user asks for local pages, local actions publish, or benchmark refresh.
---

# Local Pages & benchmarks (no Actions)

Public sites go stale when only `main` pushes trigger `pages.yml`. Use **local build + `gh-pages` push** instead.

| Site | URL |
|------|-----|
| Benchmarks | https://li-langverse.github.io/benchmarks/ |
| Development overview | https://li-langverse.github.io/roadmap/development-overview/ |

**Auth:** `lic/scripts/with-github-env.sh` + `GH_TOKEN` (contents write) or `gh auth login`.

## One command (both repos)

From **benchmarks**:

```bash
cd benchmarks
LIC_ROOT=../lic ./scripts/refresh-live-sites.sh
```

Env:

| Variable | Effect |
|----------|--------|
| `SKIP_BENCH=1` | Skip ingest; redeploy existing `summary.json` |
| `SKIP_ROADMAP=1` | Skip roadmap regen/deploy |
| `LIC_ROOT` | Path to **lic** for CSV ingest |

## Benchmarks only

```bash
cd benchmarks
LIC_ROOT=../lic ./scripts/run-full-benchmark-suite.sh   # tiers 0–4 (tier 5 ecosystem off by default)
# or after lic CI produced CSV:
LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/deploy-pages-local.sh --build
```

### Display policy (mandatory)

- **Hardware** must appear in `summary.json` → `hardware` block (CPU, flags, host uname, git shas). Ingest: `scripts/ingest/build_summary.py`.
- **Ratios only** on the public dashboard — **cpp = 1.00×** reference (or catalog `compare_oracle` for HTTP). Do **not** publish absolute wall times in UI or release notes.
- Table column: `Ratio` (`0.818× vs cpp`), not raw Li/C++ seconds.

## Roadmap only

```bash
cd roadmap
gh auth login   # or with-github-env
python3 scripts/regenerate-development-overview-md.py
./scripts/deploy-pages-local.sh --build
```

- **Live PR queue** updates in the **browser** (`development-overview-live.js`) — no redeploy for queue-only changes.
- Redeploy when **`docs/development-overview.md`** snapshot tables change.

## Actions fallback

```bash
./scripts/deploy-pages-local.sh --workflow
```

## Agent checklist (end of run)

1. `curl -sI` both URLs → HTTP 200
2. Benchmarks page shows **Hardware & reference** banner and **×** units on charts
3. `summary.json` has `hardware.cpu_model_primary` and rows without `li_value`/`cpp_value`
4. Roadmap snapshot date in HTML matches `regenerate-development-overview-md.py` run
5. Post links + `generated_at` in handoff; do not claim deploy success without push auth

## Related

- Skill `run-local-ci-gha-quota` — PR CI without Actions (merge gate JSON)
- `benchmarks/scripts/deploy-pages-local.sh` — single-repo Pages push
- `roadmap/scripts/regenerate-development-overview-md.py` — refresh stale snapshot MD
