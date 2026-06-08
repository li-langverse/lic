# Swarm coverage — UX dimension (2026-06-04)

**Goal id:** `swarm_coverage`  
**Research dimension:** `ux`  
**Worker:** `7216f11c`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/` (staged under `lic` until repo mounted)

## Summary

Swarm gap orchestration for UX is **healthy at the plan-loop layer** (24/25 studio todos complete) but **degraded at the ecosystem layer** (grade D, 64 open gaps, CI-red metrics PRs). UX debt is split across **`plan_debt`** (studio plan, `orch-r4`), **`competitor_feature`** (viz/studio vertical stubs), and **benchmark unknowns** (`viz_*` rows) — not yet classified as `ui_ux` in the registry.

## UX signals (orch-r4)

| Signal | State | Evidence |
|--------|-------|----------|
| Studio plan loop | 24 done, 1 pending (`studio-ux-25`) | `docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md` |
| Native palette / agent chrome | Done (UX-04, UX-06) | plan todos 22–23; `packages/li-ui/CHANGELOG.md` |
| wgpu swapchain on GPU runner | Done (21, 24) | plan todos 21, 24 |
| Scientific viz parity | Stub | `verticals.toml` id scientific_viz |
| Benchmark viz suite | Unknown (no tier-1 evidence) | briefing `ecosystem_audit.benchmarks.unknown` |
| `ui_ux_quality` goal | Enabled; agent `gui_ux_tester` | `li-cursor-agents/config/research-goals.yaml` |

## Orchestration recommendations

1. Route **`studio-ux-25`** to **`gui_ux_tester`** (`ui_ux_quality`), not a new loop.
2. On ingest success, add **`gap_kind: ui_ux`** rows for inspector panels, linked views, colormap (benchmark ids).
3. Fix **`swarm-gap-ingest.py`** and bake **PyYAML** so `studio-ux-21/24` apply patches reach plan loop files in CI.
4. Unblock **benchmarks** catalog PRs before refreshing scorecard metrics (avoid churn on failing CI).

## north_star_fit

- **Provable:** UX gates reference bench hooks (`studio_palette_bench_native`, wgpu readback) — keep proof artifacts in CI.
- **Easy:** Command palette + agent chrome native paths reduce operator friction for swarm supervisors.
- **Fast:** Defer GPU perf marketing until swapchain CI is green (`studio-ux-24`).

## Citations

- Run digest: `li-cursor-agents/data/runs/swarm_observer-1780603303884.md`
- Orchestrator note: `lic/docs/ecosystem/orchestrator-notes/2026-06-04-orch-ux-7216f11c.md`
- Scorecard: `benchmarks/data/latest/ecosystem-quality-report.json`
- Gap actions: `benchmarks/data/latest/swarm-gap-actions.json`
