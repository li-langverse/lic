# PH-2e / 2f / 2i / 7e: Lean/VC evidence closure (G-lean, G-vc, G-math)

> **Issue:** [#32](https://github.com/li-langverse/lic/issues/32) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first — tracker rows must cite shell corpora and gap-register evidence, not narrative-only updates  
> **North star fit:** scientific_computing, hpc, compiler verification — **PH-2e**, **PH-2f**, **PH-2i**, **PH-7e**, **G-lean**, **G-vc**, **G-math**  
> **Learned from:** [master plan §2e–2f / 2i / 7e](2026-05-14-li-master-plan.md), [proof-corpus-roadmap](../../verification/proof-corpus-roadmap.md), [provability-gaps](../../verification/provability-gaps.md), [math-linalg surface](2026-05-16-li-math-linalg-surface.md)

## Goal

Close **partial** master-plan tracker rows for **Phase 2e**, **2f**, **2i**, and **7e** against the provability register (**G-lean**, **G-vc**, **G-math**) with auditable evidence. Each closure PR must cite the same shell corpora that prove the claim (`contracts_discharge_corpus.sh`, `check-autovc-open-goals.sh`, `discharge_linalg_int_lean.sh`, or named successors).

This issue is the **umbrella** for three narrower tracks already filed: [#17](https://github.com/li-langverse/lic/issues/17) (2f / G-lean), [#21](https://github.com/li-langverse/lic/issues/21) (2e / G-vc), and [#25](https://github.com/li-langverse/lic/issues/25) (partial-row evidence). Close those as **superseded** when the corresponding sub-phase exit gates below land.

## Problem (evidence drift)

| Source | Claim today | Drift |
|--------|-------------|-------|
| Master plan tracker ~L455 | 2f **partial**; `sqrt_open_bound` **intentional open** | Still-open table L36 says **closed slice** via `Li.Discharge` |
| Gap register L85 | G-lean: `sqrt_open_bound` **intentional open** | Proof-corpus L30: **Closed** specimen |
| `contracts_discharge_corpus.sh` L32–37 | Probes open VC on `sqrt_open_bound` | Script tolerates both discharged and open probe |
| Master plan ~L447 | 2i **partial**; float `@` Props **closed** (`mat2_at2_eval`) | G-lean L36: `mat2_at2_eval` **still open** (trusted vs MIR `@`) |
| Master plan ~L458 | 7e **partial**; tier-1 advisory | G-math closed-slice bullets may overclaim vs [#463](https://github.com/li-langverse/lic/issues/463) red rows |

**Root cause:** tracker, gap register, and corpus roadmap were updated on different dates without a single **evidence matrix** tying each checkbox to a named script outcome.

## Non-goals

- Marking **G-lean**, **G-vc**, or **G-math** **Done** — partial evidence only until universal Lean kernel discharge.
- Compiler codegen for SIMD matmul blocked/IKJ paths (tracked in [#463](https://github.com/li-langverse/lic/issues/463); do not weaken `threshold_ratio_cpp`).
- Editing `trusted.lean` without a human-approved issue (swarm mandate).
- Self-merging master-plan governance edits beyond Doc-c / tracker honesty.
- Implementing product code in the **plan** PR (docs-only).

## Dependencies

| ID | Relationship |
|----|--------------|
| **PH-2e** | VC generation — call-site `requires`, refinements, open-goals policy |
| **PH-2f** | Lean 4 gate on `lic build` — Tier B `lake build AutoVC`, `--strict-lean` |
| **PH-2i** | Math surface types — shape errors, P-linalg closed VCs, broadcast slices |
| **PH-7e** | Math → SIMD MIR — pure-Li lowering; perf advisory separate from proof closure |
| **G-lean** | Canonical Lean gate row — source of truth for strict/open-VC story |
| **G-vc** | Canonical VC emission row |
| **G-math** | Canonical math/linalg row — includes explicit SIMD matmul **deferral** |
| **#17** | Sub-track: 2f / sqrt_open_bound / default Lean gate |
| **#21** | Sub-track: 2e / contracts exit gates |
| **#463** | Sub-track: tier-1 red bench honesty (perf, not proof certificate) |
| **P-float**, **P-linalg** | Proof backlog items cited in closure PRs |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **Evidence matrix** — table mapping each partial tracker bullet → script → pass/fail/intentional-open | Matrix appended to issue #32 or linked from this plan |
| **B** | **G-lean / PH-2f — sqrt story** — reconcile `sqrt_open_bound`: if `Li.Discharge.sqrt_open_bound_spec` + trusted libm axiom discharge under `--allow-open-vc` probe, update master plan + gap register to **closed slice (trusted)**; remove “intentional open” where corpus says closed | `contracts_discharge_corpus.sh` green; `proof-corpus-roadmap.md` L30 = gap register L36 = tracker |
| **C** | **G-lean / PH-2f — strict gate** — document Tier B vs `--strict-lean` vs `--allow-open-vc`; cite `check-autovc-open-goals.sh` + `scripts/ci.sh` | `proof-db/lemmas/G-lean-autovc-strict.toml` evidence paths current |
| **D** | **G-lean — mat2 deferral** — tracker explicitly lists `mat2_at2_eval` trusted-vs-MIR `@` as **open** until MIR witness lands; link `mat2_at2_mir_codegen_lean_gap.sh` | No “float `@` Props closed” without “eval vs MIR” caveat |
| **E** | **G-vc / PH-2e** — enumerate remaining open VC classes: opaque `vec3_dot`-style returns, loop body vs closed-form `ensures`; add exit checklist to [#21](https://github.com/li-langverse/lic/issues/21) | `vc_emit_contracts.sh`, `mir_vc_witness.sh`, `discharge_caller_requires_*.sh` cited in same PR as doc edits |
| **F** | **G-math / PH-2i** — matrix `@` shape rules: cite `li-tests/math_linalg/`, `contracts_verify/linalg_*_closed.li`, `discharge_linalg_int_lean.sh`; defer full NumPy-rank broadcast to [#526](https://github.com/li-langverse/lic/issues/526) | Tracker 2i row lists closed vs deferred slices with test paths |
| **G** | **G-math / PH-7e — SIMD matmul deferral** — explicit “**deferred until**” criteria: (1) loop matmul MIR witness, (2) `mat2_at2_eval` Lean bridge, (3) tier-1 green per [#463](https://github.com/li-langverse/lic/issues/463) before “closed slice” wording | Phase 7e tracker says **partial — SIMD matmul deferred** with three bullets |
| **H** | **Doc sync PR** — single implementation PR updates `provability-gaps.md`, master plan tracker ~L447–458, `proof-corpus-roadmap.md` run-results table; bump **Last updated** | `./scripts/check-doc-provability-claims.sh` green |

## Tests / verification (cite in every closure PR)

| Check | Command / artifact | Gap |
|-------|-------------------|-----|
| Closed discharge corpus | `./li-tests/tooling/contracts_discharge_corpus.sh` | **G-lean**, **G-vc** |
| Open-goal inventory | `./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean` | **G-lean** |
| P-linalg closed specimens | `./li-tests/tooling/discharge_linalg_int_lean.sh` | **G-math**, **PH-2i** |
| Manifest honesty | `./li-tests/run_all.sh contracts_verify` (`prove_lean_ok` vs `verify_open_ok`) | **G-test-verify** |
| VC emission | `./li-tests/tooling/vc_emit_contracts.sh`, `mir_vc_witness.sh` | **G-vc** |
| Math compile corpus | `./li-tests/run_all.sh math_linalg` | **PH-2i** |
| Tier-1 advisory (reference) | `./scripts/check-tier1-li-vs-cpp.sh` | **PH-7e** — cite gaps; do not green-wash [#463](https://github.com/li-langverse/lic/issues/463) |
| Mat2 MIR gap probe | `./scripts/proof-explorer-gates/wp-catalog-honesty.sh` → `mat2_at2_mir_codegen_lean_gap.sh` | **G-lean** deferral |
| Doc claim guard | `./scripts/check-doc-provability-claims.sh` | Doc-c |

## Provability mapping

| Gap / phase | Move | Notes |
|-------------|------|-------|
| **G-lean** | Stay **Partial** → **honest Partial** | Reconcile sqrt closed-slice vs intentional-open drift; keep `mat2_at2_eval` open |
| **G-vc** | Stay **Partial** | Closed: call-site `requires`, const-local, sqrt bound (trusted). Open: opaque returns, loop ensures |
| **G-math** | Stay **Partial** | Closed: P-linalg int/float specimens, shape tests. **Deferred:** SIMD blocked matmul, full float `@` MIR witness |
| **PH-2e** | Tracker **partial** with evidence links | Not Done until P-refine / P-ensures-witness slices close |
| **PH-2f** | Tracker **partial** with evidence links | Not Done until universal kernel discharge (research) |
| **PH-2i** | Tracker **partial** | Broadcast len-1 closed ([#574](https://github.com/li-langverse/lic/issues/574)); full rank deferred |
| **PH-7e** | Tracker **partial — SIMD matmul deferred** | Perf closure is [#463](https://github.com/li-langverse/lic/issues/463); proof closure is sub-phase G |

## Rollout

1. Merge this **plan** PR; human adds **`plan-approved`** on #32.
2. **Sub-phase A** — post evidence matrix as issue comment (can be first follow-on PR appendix).
3. **Sub-phase H** — docs-only implementation PR(s) for B–G reconciliation; each PR description must name **G-lean**, **G-vc**, or **G-math** (Doc PR rule).
4. Close #17, #21 when B+C and E respectively satisfy exit gates; reference #32 in close comment.
5. Keep #463 open for tier-1 perf; do not conflate with proof evidence on #32.

## Human-only

- [ ] Label **`plan-approved`** on #32 before docs implementer runs sub-phase H.
- [ ] Remove **`plan-needed`** from #17 if present, after plan merge (umbrella is #32).
- [ ] Approve any `trusted.lean` change for `mat2_at2_eval` bridge via separate human issue.
- [ ] Acknowledge tier-1 advisory waiver via master plan amendment, not silent G-math bullet edit.
