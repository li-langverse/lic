# Swarm coverage — performance dimension (2026-06-04)

**Goal:** `swarm_coverage` · **Worker:** `03599ebd`  
**Publish target:** `research-findings/whitepapers/swarm_coverage/performance/`  
**north_star_fit:** Li ecosystem agent swarm — performance gaps block “blazingly-fast” pillar after proof (PH-7e, PH-5b).

## Abstract

The Li agent swarm’s performance posture is **degraded by measurement and orchestration gaps**, not SDK latency. One hundred thirty-plus benchmark rows are `unknown` in the latest ecosystem audit; eight tier-1 **competitor_feature** red gaps remain open in the swarm-gap registry. Gap ingest/apply — the pipeline that routes perf work to `bench_improver` and `numerics_researcher` — is blocked by missing PyYAML and (until this pass) a syntax error in `swarm-gap-ingest.py`. Unattended swarm operation is unsafe until benchmarks CI and control-plane observer caches are restored.

## Evidence base

| Artifact | Path |
|----------|------|
| Quality scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Agent briefing | `/workspace/benchmarks/data/latest/agent-briefing.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Gap actions | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Observer report | `/app/data/runs/swarm_observer-1780599702380.md` |

## Tier-1 performance gaps (registry)

| Benchmark | vs cpp | PH | Handoff |
|-----------|--------|-----|---------|
| `matmul_naive` | 1.73× | PH-7e | `bench_improver`, `numerics_researcher` |
| `num_gmres` | 1.68× | PH-5b | `numerics_researcher` |
| `num_opt_line_search` | 2.00× | PH-5b | `numerics_researcher` |
| `num_integ_euler` | 1.40× | PH-5b | `numerics_researcher` |
| `num_integ_verlet` | 1.35× | PH-5b | `numerics_researcher` |
| `cloth_swing` | 1.37× | PH-5b | `numerics_researcher` |
| `orbit_two_body` | 1.69× | PH-5b | `numerics_researcher` |
| `schrodinger_1d_barrier` | 1.77× | PH-5b | `numerics_researcher` |

Master-plan partials (`phase-7e` SIMD matmul, `phase-8p` parallel compile) remain **plan_debt** — proof-before-perf ordering preserved.

## Orchestration performance (meta)

- **Retry tax:** Prior `org-research-audit.jsonl` entries show multi-minute `swarm_observer` retries when DB persist failed — throughput loss without durable run history.
- **Grader path:** Without `LI_CURSOR_AGENTS_ROOT=/app`, `swarm_execution` scored 65 with `runs_sampled: 0`; correcting the path raises execution score to 100 for this host (single active run).
- **Observer blind spot:** Empty `data/control-plane/state.json` prevents programmatic retry/heal — operators pay full SDK cost for manual meta audits.

## Recommendations

1. Unblock **benchmarks** CI on catalog/metrics PRs so red/unknown bench rows refresh on main.
2. Install **PyYAML** in agent runtime; run `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` each briefing cycle.
3. Dispatch **`bench_improver`** then **`numerics_researcher`** on tier-1 red `gap_id`s above — cite PH ids on handoffs.
4. Set default **`LI_CURSOR_AGENTS_ROOT`** in `ecosystem-quality-grade.py` for container layouts where agents root is `/app`.

## References

- Li master plan: PH-7e (SIMD/parallel), PH-5b (numerics/PDE)
- Swarm architecture: `docs/ecosystem/swarm-architecture.md` (agents control plane, retired systemd loops)
