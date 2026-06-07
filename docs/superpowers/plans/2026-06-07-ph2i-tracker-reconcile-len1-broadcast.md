# PH-2i: master-plan tracker reconcile — length-1 broadcast closed (G-math)

> **Issue:** [#386](https://github.com/li-langverse/lic/issues/386) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest tracker vs shipped tests), **Easy** (sub-plan checkboxes match master plan)  
> **North star fit:** Scientific computing / linalg surface — **PH-2i**, **PH-2i-b**, **PH-7e**, **G-math**  
> **Learned from:** [2026-05-16-li-math-linalg-surface.md](./2026-05-16-li-math-linalg-surface.md), [2026-05-25-2i-broadcast-plan-tracker.md](../../release-notes/2026-05-25-2i-broadcast-plan-tracker.md), [2026-06-03-ph2i-close-stale-462-broadcast-reconcile.md](./2026-06-03-ph2i-close-stale-462-broadcast-reconcile.md), [linear-algebra.md](../../language/linear-algebra.md)

## Goal

Align **Phase 2i** master-plan tracker row (`2026-05-14-li-master-plan.md:447`) with the sub-plan **2i-broadcast** checkbox (`2026-05-16-li-math-linalg-surface.md:174`) and shipped compile tests. Mark **length-1 broadcast** as a **closed compile slice** in tracker prose; keep `- [ ] Phase 2i` until full NumPy-rank broadcast is deferred/tracked (**G-math** / **AL-10**) and **PH-7e** tier-1 gaps (e.g. `matmul_blocked` yellow) remain open.

## Non-goals

- Product/compiler changes — length-1 broadcast MIR/codegen already on `main`.
- Closing **PH-2i** checkbox to `[x]` — full-rank broadcast and tier-1 perf slices still open.
- Lean `Discharge.lean` broadcast witness (**#574** / PR #900) — separate proof_gap lane.
- Weakening tier-1 `threshold_ratio_cpp` or editing `trusted.lean`.
- Duplicating sibling docs PRs from **#618** / **PR #866** — coordinate tracker edits in one implementation PR.

## Duplicate check

| Item | Status |
|------|--------|
| **#386** | This plan — tracker line 447 vs sub-plan 2i-broadcast |
| **#618** | Closed — stale **#462** reconcile; overlapping G-math sync (coordinate, do not double-edit) |
| **#526** | Closed + **plan-approved** — NumPy-rank defer criteria; cite in tracker **open** slice |
| **PR #997** | Draft plan for **#462** — compile evidence audit; sub-phase C overlaps — merge tracker PR once |
| **Sub-plan 2i-broadcast** | `[x]` since 2026-05-25 — source of truth for length-1 slice |

## Dependencies

| ID | Role |
|----|------|
| **PH-2i**, **PH-2i-b** | Math/linalg surface — length-1 broadcast compile slice **done** |
| **PH-7e** | Tier-1 lowering — `matmul_blocked` yellow (1.298×) stays in **open** tracker text |
| **G-math** | Gap register — split closed compile slice vs open full-rank + tier-1 rows |
| **AL-10** | Future `packages/linalg` home for full-rank broadcast if deferred past Phase 2i |
| **#526** | Closed defer policy for NumPy-rank — link from master plan **open** bullet |
| Human | **`plan-approved`** before docs/tracker implementation PR |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **Evidence audit** — confirm sub-plan `[x]` matches manifest + tests on `main` | `broadcast_len1_{add,mull,pow}_*.li` + `broadcast_invalid_len2_vs_len4.li` green under `./li-tests/run_all.sh math_linalg` |
| **B** | **Master plan row 447** — replace ambiguous “length-1 broadcast still open” with **closed compile slice** wording; keep `- [ ] Phase 2i`; list **open**: full NumPy-rank (**#526** / **AL-10**), float Lean Props, **PH-7e** tier-1 yellow rows | Line 447 consistent with sub-plan `:174` and handbook `linear-algebra.md:30` |
| **C** | **G-math summary** — `provability-gaps.md` closed slice cites `broadcast_len1_*`; open slice cites NumPy-rank + Lean witness; bump **Last updated** | No contradiction with `plan-completion-audit` phase `2i` = partial |
| **D** | **v2 backlog table** (`master-plan.md:503`) — narrow “broadcast” to “full-rank broadcast + tier-1 strict rows” | **2i / 7e** row honest vs closed len-1 slice |
| **E** | **Close #386** — comment with before/after tracker excerpt + link to docs PR | Issue closed after sub B–D land |

## Tests / benches

| ID | Path | Outcome | Role |
|----|------|---------|------|
| REQ-2i-b-len1-add | `li-tests/math_linalg/broadcast_len1_add_float4.li` | `compile_ok` | float `+` len-1 → len-N |
| REQ-2i-b-len1-mul | `li-tests/math_linalg/broadcast_len1_mul_int4.li` | `compile_ok` | int `*` broadcast |
| REQ-2i-b-len1-pow | `li-tests/math_linalg/broadcast_len1_pow_int4.li` | `compile_ok` | int `**` broadcast |
| REQ-2i-b-reject | `li-tests/math_linalg/broadcast_invalid_len2_vs_len4.li` | `compile_fail` | non-len1 mismatch |
| REQ-2i-lean-gap | `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh` | CI PASS | Lean boundary documented |

**Bench (open, PH-7e):** `matmul_blocked` tier-1 yellow ~1.298× C++ — cite in tracker **open** text; no threshold changes in this plan.

**Gate:** `./li-tests/run_all.sh math_linalg` green; no manifest outcome edits in plan PR.

## Provability / G-* updates

| Gap | Before | After (implementation PR) |
|-----|--------|---------------------------|
| **G-math** | Partial; tracker implies len-1 broadcast open | Partial; **closed compile slice** = len-1 element-wise + reject specimen; **open** = NumPy-rank (#526), Lean witness (#574), tier-1 strict rows (**PH-7e**) |
| **G-lean** | Partial | Unchanged until PR #900 merges |
| **G-math-syn** | Partial | Unchanged |

## PH tracker mapping

| PH ID | This plan | Remaining owner |
|-------|-----------|-----------------|
| **PH-2i** | Reconcile partial row prose; checkbox stays `[ ]` | Full-rank defer (#526 / AL-10), Lean (#574) |
| **PH-2i-b** | Len-1 broadcast **done** in tracker text | — |
| **PH-2i-broadcast** | Align master plan with sub-plan `[x]` | — |
| **PH-7e** | Keep `matmul_blocked` yellow in **open** slice | benchmarks / 7e implementer |

## Proposed tracker text (line 447)

Replace current partial bullet with (docs PR implements verbatim):

```markdown
- [ ] Phase 2i — Math / linalg surface — **partial:** **2i-a/c** (#148); **2i-b** `norm`, `sum`/`dot`, `reductions/`, same-length `**`, prelude `axpy`, scalar×array; **2i-broadcast len-1** (`array[1]`→`array[N]` element-wise) **compile slice done** (`broadcast_len1_*.li`, sub-plan `[x]`); **open:** full NumPy-rank broadcast (**G-math**, [#526](https://github.com/li-langverse/lic/issues/526) / **AL-10** defer); float `@` Props closed (`mat2_at2_eval`); **PH-7e** tier-1 yellow (`matmul_blocked`)
```

## Rollout

1. Merge this plan PR (draft → ready for review).
2. Maintainer adds **`plan-approved`** on **#386**; remove **`plan-needed`**.
3. **Docs-only implementation PR** (sub-phases B–D): single PR for master plan + `provability-gaps.md`; coordinate with any open **#618** follow-up to avoid duplicate edits.
4. Close **#386** (sub-phase E) when tracker + G-math sync lands.
5. Track NumPy-rank (**#526** policy) and **PH-7e** perf separately before PH-2i → `[x]`.

## Human-only

- [ ] Label **`plan-approved`** on **#386** before docs implementation agents run.
- [ ] Confirm **plan-completion-audit** phase `2i` remains **partial** after edit (expected).
- [ ] Do not promote PH-2i to done until full-rank defer is explicit and tier-1 strict rows close.
