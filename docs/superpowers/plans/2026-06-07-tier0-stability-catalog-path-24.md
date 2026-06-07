# tier0_stability catalog path reconciliation (lic#24)

> **Issue:** [#24](https://github.com/li-langverse/lic/issues/24) · **Repo:** li-langverse/lic (+ li-langverse/benchmarks catalog)  
> **Vision:** **Provable** (tier-0 correctness gate before perf claims), **Easy** (li-tests manifest integration), **Fast** (stability smoke only after proof path green)  
> **Learned from:** [vision-and-roadmap.md](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md), [engineering-standards.md](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/engineering-standards.md), [catalog path reconciliation PH-5b](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/plans/2026-05-31-catalog-path-reconciliation-ph5b.md), [2026-05-26 wave-a tier0 li-tests hygiene](../../release-notes/2026-05-26-wave-a-tier0-li-tests-hygiene.md)

## Goal

Resolve the **tier0_stability** catalog gap: org dashboard ingest must find a real harness path on **lic** `main`, without duplicating benchmark drivers or weakening thresholds. Close **lic#24** with an auditable ADR-style decision and green audit/ingest evidence.

## Decision (ADR)

**Choose Option 2 — retarget catalog path — with lic workload tree at the canonical location.**

| Option | Verdict | Rationale |
|--------|---------|-----------|
| 1. Add harness under `lic/benchmarks/tier0_correctness` | **Reject** | Violates single-repo layout: drivers live in **benchmarks** (`verify.py`, `stability.py`, `bench.py --tier 0`); **lic** owns sources + `lic build` contract tests only ([benchmarks README](../../../benchmarks/README.md)). |
| 2. Retarget catalog row + document | **Accept** | Catalog on **benchmarks** `main` already points to `li-tests/benchmarks/tier0_correctness`; path exists on **lic** `main` with three `.li` smokes; harness reads via `LIC_ROOT`. |

**Canonical mapping**

| Field | Value |
|-------|-------|
| Catalog id | `tier0_stability` |
| `repo` | `lic` |
| `path` | `li-tests/benchmarks/tier0_correctness` |
| `metric` | `stability` (tier-0 = verify + MD stability stress; not wall_time) |
| `ph_ids` | `PH-5b` |
| Harness (benchmarks) | `harness/verify.py` (`.li` smokes), `harness/stability.py` (MD invariants), `bench.py --tier 0` |

**Superseded path:** `benchmarks/tier0_correctness` on **lic** — never shipped on `main`; issue body predates Wave A li-tests migration (2026-05-26).

## Non-goals

- Copying **benchmarks** harness into **lic** (`benchmarks/tier0_correctness/` tree with `verify.py`).
- Weakening `threshold_ratio_cpp` or marking green without measured verify/stability CSV rows.
- Claiming **G-math** / **G-par** closure from catalog edits alone.
- Retargeting workloads into **benchmarks** repo (ingest-only per AGENTS.md).

## Dependencies

- **PH-5b** — tier-0/1/2 harness ownership split (lic sources, benchmarks drivers).
- **benchmarks** [#179](https://github.com/li-langverse/benchmarks/issues/179), [tier-2 catalog sync](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/plans/2026-05-18-tier2-catalog-lic-sync.md) — parallel catalog honesty track (references lic#24).
- **lic** `scripts/ci.sh` tier-0 phase — runs `$BENCHMARKS_ROOT/scripts/run-bench.sh --tier 0` after `patch-benchmarks-tier0-paths.sh`.
- Human: **`plan-approved`** on #24 before any product-code PR beyond doc/ADR.

## Sub-phases

| Sub | Deliverable | Owner | Exit gate |
|-----|-------------|-------|-----------|
| A | **ADR + plan** (this doc) | lic | Draft PR linked from #24 |
| B | **Catalog confirm** — `tier0_stability.path = "li-tests/benchmarks/tier0_correctness"` on benchmarks `main` | benchmarks | `GET …/contents/li-tests/benchmarks/tier0_correctness` → 200 |
| C | **lic workloads** — maintain `float_binop.li`, `md_energy_single_step.li`, `three_body_invariants.li` + `li-tests/manifest.toml` rows | lic | `./scripts/check-bench-harness-contract.sh` exit 0 |
| D | **Harness wiring** — `verify.py` iterates `lic_root()/li-tests/benchmarks/tier0_correctness/*.li`; tier-0 CI via benchmarks | benchmarks + lic | `bench.py --tier 0` + `verify.csv` rows for all three smokes |
| E | **Ingest mapping** — dashboard row `tier0_stability` reads verify/stability CSV, not `unknown` | benchmarks | `./scripts/ingest/ingest-lic.sh` smoke; row status ≠ `unknown` |
| F | **Audit closure** — `plan-completion-audit.py` with `LIC_ROOT=../lic` | benchmarks | `tier0_stability` absent from actionable `catalog_gaps` |
| G | **Issue close** — update #24 title/body or close with audit evidence | lic | `org-close-issue.py` or maintainer close |

## Tests / benches

| Gate | Command | Expected |
|------|---------|----------|
| lic contract | `./scripts/check-bench-harness-contract.sh` | 6 tests OK |
| tier-0 bench | `LIC_ROOT=. BENCHMARKS_ROOT=../benchmarks ../benchmarks/scripts/run-bench.sh --tier 0` | verify + stability CSV |
| lic CI slice | `./scripts/ci.sh` (tier-0 phase) | exit 0 |
| catalog audit | `LIC_ROOT=../lic python3 ../benchmarks/scripts/plan-completion-audit.py` | no actionable gap for `tier0_stability` |
| dashboard | `python3 ../benchmarks/scripts/check-dashboard-invariants.py` | row present, honest status |

**REQ mapping:** REQ-BENCH-CATALOG-1 (honest index), REQ-BENCH-TIER0-1 (verify before timing).

## Provability / gap updates

| Gap | Move | Notes |
|-----|------|-------|
| **G-math** | Partial (unchanged) | Tier-0 proves `lic build` + invariant smokes; not full numerics closure |
| **G-meta** | Partial | AutoVC / open-VC policy on tier-0 smokes per wave-a hygiene |
| **G-par** | N/A | No perf claim at tier 0 |

Proof-db cross-links already cite tier-0 sources (`proof-db/physics/*/catalog.json`, `docs/verification/proof-database/entries/physics-*.toml`).

## Rollout

1. **lic** draft PR: this plan (linked from #24) — **no product code in plan PR**.
2. After **`plan-approved`**: scoped **benchmarks** PR if ingest mapping (sub-phase E) still shows `unknown` (expected small diff in ingest or catalog ADR footnote only).
3. **lic** PR (optional): one-line cross-link in `benchmarks/README.md` pointing to canonical `li-tests/benchmarks/tier0_correctness`.
4. Re-run audit (sub-phase F); close #24 when green.

## Human-only

- [ ] Label **`plan-approved`** on #24 before implementation agents run sub-phases D–G.
- [ ] Confirm dashboard UX for `metric = stability` tier-0 rows (verify badge vs timing chart).
- [ ] Merge plan PR; do not self-merge governance/roadmap PRs.

## north_star_fit

**Domain:** correctness / stability smoke (scientific computing proof gate) · **PH:** PH-5b · **Pillar order:** proof (tier-0 verify) → easy (li-tests manifest) → fast (deferred to tier 1+).
