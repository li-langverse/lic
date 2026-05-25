# Release notes: 2026-05-25 — bench-harness-fill-registry

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** feat/bench-harness-fill-all-registry  
**PH / REQ:** PH-5b competitive benchmarks  
**Author:** agent

---

## Summary (one sentence)

Adds **116** family-template harness dirs, **tier-7** registry CSV alias ingest (`bench_registry.py`), and WP1 **num_*** / **md_*** timing harnesses so benchmarks dashboard can measure algo_registry catalog rows.

## Agent continuation (required)

1. **Read:** `benchmarks/harness/bench_registry.py`, `scripts/generate-registry-harnesses.py`, `benchmarks/harness/bench.py` (`--tier 7`, `_wp1_num_bench_specs`, md wp1 tuple).
2. **Run:** `CC=clang CXX=clang++ python3 benchmarks/harness/bench.py --tier 12 --skip-verify --runs 3`; `python3 benchmarks/harness/bench.py --tier 7`; commit `benchmarks/results/latest.csv`.
3. **Then:** In **benchmarks** repo run `LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`; verify dashboard ≥79% measured.
4. **Blocked on:** Li `build` failures for `cloth_swing`, `euler_fluid_2d`, `combustion_passive`, `wind_field_bc`, `rigid_body_stack`, `horner_pure_li` (compiler, not harness layout).

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Harness | `benchmarks/tier1_micro/{num_*,fft_1d_fixed}/`, `tier2_physics/md_*/` smoke dirs | `generate-registry-harnesses.py` |
| Runner | `benchmarks/harness/bench_registry.py` — family clone + optional `REGISTRY_RUN_TIMINGS=1` | 96 alias ids |
| Runner | `benchmarks/harness/bench.py` — `--tier 7` | — |
| CSV | `benchmarks/results/latest.csv` — tier1/2 + registry aliases | Local `CC=clang` run |
| Scripts | `scripts/generate-registry-harnesses.py` | — |

## Not changed (scope fence)

- **algo_registry.json** algorithm count (126) and semantics.
- Full physics fidelity for qm_*/cfd_* (template timing only).
- **compiler/** codegen fixes for failing Li tier-2 builds.
- tier5 HTTP exploit drivers.

## Breaking changes

None.

## Security

N/A — local benchmark timing only.

## Performance

Template-alias rows duplicate parent kernel timings (documented `family-template=` flags in CSV); real per-id timings require `REGISTRY_RUN_TIMINGS=1`.

## Downstream

| Repo | Action |
|------|--------|
| **benchmarks** | Merge `feat/bench-fill-all`; ingest CSV |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **Registry benchmark harness fill:** family-template dirs + `bench_registry.py` tier-7 CSV aliases for dashboard catalog — [2026-05-25-bench-harness-fill-registry.md](docs/release-notes/2026-05-25-bench-harness-fill-registry.md).
```
