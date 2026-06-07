# Master plan PH-row + G-* reconciliation (lic#16)

> **Issue:** [#16](https://github.com/li-langverse/lic/issues/16) · **Repo:** li-langverse/lic  
> **Vision:** Provability pillar (Doc-c honesty, agent routing) · **Learned from:** [master plan](2026-05-14-li-master-plan.md), [provability-gaps.md](../../verification/provability-gaps.md), [plan-cross-links.md](../../ecosystem/plan-cross-links.md), [2026-05-25-plan-checkbox-audit-wave.md](../../release-notes/2026-05-25-plan-checkbox-audit-wave.md)

## Goal

Reconcile **partial** master-plan tracker rows and **G-*** register debt so swarm agents, `plan-completion-audit.py`, and `swarm-gap-ingest.py` can distinguish **scaffold** vs **shipped** — without marking `[x]` without same-PR evidence or falsely closing **G-*** rows to **Done**.

This is the **umbrella orchestration plan** for lic#16. Proof/compiler work stays in child issues (#17, #21, #32, …); this plan defines evidence rules and doc-only reconciliation waves.

## Non-goals

- Closing any **G-*** row to **Done** without a proof-surface PR in the same merge
- Weakening `threshold_ratio_cpp` or benchmark gates to greenwash partial rows
- `trusted.lean` edits (human-approved issues only)
- Product/compiler implementation in the plan PR itself

## Dependencies

| Dependency | Role |
|------------|------|
| [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) | PH tracker source of truth |
| [provability-gaps.md](../../verification/provability-gaps.md) | **G-*** register |
| `benchmarks/scripts/plan-completion-audit.py` | `master_plan_open`, checkbox drift |
| Child plans (see matrix below) | Scoped proof/doc implementers |
| Human merge + **`plan-approved`** on #16 | Before `issue_implementer` doc waves |

## Sub-phases

| Sub | Deliverable | Exit gate | Owner |
|-----|-------------|-----------|-------|
| **16-A** | Post evidence matrix on #16 (PH → shell corpus → **G-***) | Matrix comment + link to this plan | issue_planner |
| **16-B** | **Doc-c:** phase plans **02 / 03 / 07** exit gates cite **G-*** + link [still open](../../verification/provability-gaps.md#still-open-report-every-session) | `./scripts/check-doc-provability-claims.sh` green; phase exit blocks list gap IDs | #31, #29, #26 |
| **16-C** | Master plan tracker: rows **2e, 2f, 2i, 7d, 7e, H, Vision-LLM** say **partial** with PR/shell refs (no ambiguous `[x]`) | `plan-completion-audit.json` `master_plan_open` matches honest unchecked set | #16, #25 |
| **16-D** | Close stale Phase **00–03** sub-plan checkboxes where `main` ships MIR/typechecker | Same PR cites `run_all.sh` suite + file paths; optional audit skip for Phase 0 bootstrap | #16 |
| **16-E** | Reconcile swarm registry `plan_debt` after doc waves | `swarm-gap-ingest.py` + snapshot: no stale rows for reconciled PH ids | post-merge automation |

## Partial PH-row evidence matrix

Use this table for tracker edits and agent handoffs. **Do not** check master-plan `[x]` for a row until the **Still open** column is empty or explicitly deferred with a linked issue.

| PH row | Shipped on `main` (evidence) | Still open **G-*** / deferral | Child plan / issue |
|--------|------------------------------|-------------------------------|-------------------|
| **2e** | PR #83; `vc_emit_contracts.sh`, `mir_vc_witness.sh`, `contracts_discharge_corpus.sh` | **G-vc** float/opaque ensures; **G-bnd** release path | [#21](https://github.com/li-langverse/lic/issues/21) |
| **2f** | Default `lake build AutoVC`; P-linalg closed corpus (#151); `prove_lean_ok` manifest | **G-lean** kernel certificate; **G-vc** open goals; sqrt story | [#17](https://github.com/li-langverse/lic/issues/17), [#32](https://github.com/li-langverse/lic/issues/32) |
| **2i** | `li-tests/math_linalg/`; length-1 broadcast compile tests; float `@` Props (`mat2_at2_eval`) | **G-math** NumPy-rank broadcast; loop-dot proof backlog | [#20](https://github.com/li-langverse/lic/issues/20), [#526](https://github.com/li-langverse/lic/issues/526) |
| **7d** | `@vectorized(lanes=4)` scoped `for` (#150); `decorator_exploits/` CI | **G-par** structured `disjoint=`; **G-dec** MIR proc tags | [#22](https://github.com/li-langverse/lic/issues/22) |
| **7e** | Pure-Li tier-1 advisory (`matmul_naive`, `horner_pure_li`); `check-tier1-li-vs-cpp.sh` | **G-math** strict tier-1 rows; remaining SIMD matmul slices | [#27](https://github.com/li-langverse/lic/issues/27), [#32](https://github.com/li-langverse/lic/issues/32) |
| **H M1** | `packages/li-log`; TOML routes/Bearer (#158); `lis` harness | **G-net** ship gate Lean; Li `net.httpd` lib build | [#18](https://github.com/li-langverse/lic/issues/18), [#30](https://github.com/li-langverse/lic/issues/30) |
| **Vision-LLM** | `lic check --format=json`, `lic diagnose`, diagnostic-v1 schema | Manifest CI + compact test export | [#19](https://github.com/li-langverse/lic/issues/19) |

**north_star_fit:** Ecosystem doc honesty · **PH-Doc-c**, **PH-2e–2f**, **PH-2i**, **PH-7d–7e**, **PH-H**, **Vision-LLM** · proof → easy → fast.

## Doc-c exit-gate requirements (phase 02 / 03 / 07)

Each phase plan must include, directly above **Phase N exit gate**:

1. **`Proof gaps (Doc-c):`** line with anchor links to relevant **G-*** rows (already present on `main` for 02/03/07 — verify, do not regress)
2. Exit gate bullets that name **Partial** slices and cite shell scripts (not narrative-only)
3. Cross-link to [compiler task → gap map](2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting) when editing master plan in the same PR

**16-B acceptance:** `./scripts/check-doc-provability-claims.sh` passes; master plan **Doc-c** checkbox updated only when 02/03/07 all satisfy (1)–(2).

## Stale Phase 00–03 checkbox policy (16-D)

| Sub-plan file | Rule |
|---------------|------|
| `2026-05-14-phase-00-bootstrap.md` | Already `[x]` — no change unless audit script false-positive |
| `2026-05-14-phase-01-lexer-parser.md` | Add explicit checkbox table mirroring exit gate if audit counts open boxes |
| `2026-05-14-phase-02-typechecker.md` | Checkboxes already `[x]` on `main`; leave `[ ]` only for genuinely open items (e.g. full mypy parity — defer, do not fake close) |
| `2026-05-14-phase-03-mir-codegen.md` | Keep `[ ]` for **Task 5** insta snapshot (Rust path not shipped); mark codegen pipeline boxes `[x]` only with `lic build` + bounds IR evidence in same PR |

Optional benchmarks follow-up (not blocking #16 plan): teach `plan-completion-audit.py` to skip Phase 0 bootstrap boxes when master Phase 0 is `[x]` ([release note](../../release-notes/2026-05-25-plan-checkbox-audit-wave.md)).

## Tests / audit commands

```bash
./scripts/check-master-plan-gates.sh
./scripts/check-doc-provability-claims.sh
LI_REPO_ROOT=$PWD ./li-tests/run_all.sh typecheck mir_codegen math_linalg decorators
# When benchmarks sibling present:
LIC_ROOT=$PWD python3 ../benchmarks/scripts/plan-completion-audit.py
```

## Provability

| **G-*** | This plan moves |
|---------|-----------------|
| All open rows | **No status change** in plan PR — honesty only |
| **G-test-verify** | Stays **Done** — do not regress |
| Doc-c cross-links | **Partial → unchanged** until proof PRs land |

## Rollout (PR order)

1. **This PR** — plan doc + orchestrator note (docs-only)
2. Human review → merge → **`plan-approved`** on #16; remove **`plan-needed`**
3. **16-B** docs PR — phase 02/03/07 exit-gate cross-links + `check-doc-provability-claims.sh` fixes (#31)
4. **16-C/D** docs PR — master plan tracker partial wording + stale checkbox closure with evidence (#16)
5. **16-E** — `swarm-gap-ingest.py` / registry reconcile (may piggyback on 3–4)
6. Close #16 when audit shows honest `master_plan_open` and child issues own remaining proof work

## Human-only

- Merge this draft PR (governance)
- Add label **`plan-approved`** on #16
- Remove **`plan-needed`** after review
- Do not self-merge if CI fails on unrelated flakes — re-run, do not weaken gates
