# Swarm coverage — API-coverage dimension (worker `588705f7`)

**Goal:** `swarm_coverage`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/588705f7.md`  
**Generated:** 2026-06-04T12:28Z  
**north_star_fit:** Ecosystem orchestration maps incumbent **API surfaces** to Li packages and benchmark oracles under proof-before-perf (PH-2e, PH-2f, PH-5b, PH-7e).

## Abstract

The Li swarm gap registry tracks missing **API coverage** at three layers: (1) competitive vertical `kernel_or_api` declarations, (2) benchmark workload harnesses, and (3) agent-facing compiler CLI JSON. This pass audits layer (1)–(2) with registry ingest/apply and recommends control-plane routing without product implementation in `lic`.

## Method

- Read `verticals.toml` and classify `workload_class` per `kernel_or_api` row.
- Compare `agent-briefing.json` `ecosystem_audit.benchmarks.unknown` to scorecard `ecosystem_posture`.
- Run `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` after fixing ingest fallback (L229).
- Cross-check briefing `recommended_agents` vs scorecard `recommended_agents` vs org heap `flat_tasks`.

## Results

| Metric | Value | Evidence |
|--------|-------|----------|
| Vertical rows | 15 | `verticals.toml` |
| Stub/partial API rows | 12 (80%) | `workload_class` in `verticals.toml` |
| Open swarm gaps | 62 | `swarm-gap-actions.json` |
| Unknown bench workloads | 140+ | `agent-briefing.json` |
| Ecosystem grade | D (64.8) | `ecosystem-quality-report.json` |
| `unattended_safe` | false | scorecard |

### Representative API gaps (competitor_feature / plan_debt)

- **Numerics:** `matmul_naive`, `num_gmres`, integrators — tier-1 red class (PH-7e / PH-5b).
- **HTTPD:** static, LB, rate-limit benches unknown until catalog CI merges.
- **HPC libraries:** Kokkos/PETSc/FFTW/hypre rows — missing Li bindings (`gap_explorer` evidence).
- **Vision-LLM:** partial `lic check --format=json` — agent orchestration API incomplete.

## Recommendations

1. Merge benchmarks catalog-honesty PRs so `verticals.toml` on `main` matches ingest path.
2. Route open `competitor_feature` gaps to `bench_improver` + `numerics_researcher` (no perf before proof).
3. Bake `python3-yaml` and `BENCHMARKS_COMPETITIVE` in org-research Jobs.
4. Enqueue `security_auditor` for CWE catalog API gaps (19 Top25 missing).

## Limitations

- Control-plane DB and disk observer state unavailable on this host.
- `research-findings` repo not mounted — staging only under `lic/docs/research/`.
- GitHub rate limit prevented live org CI repo enumeration.

## References

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- Observer digest: `swarm_observer-1780575397584.md`
