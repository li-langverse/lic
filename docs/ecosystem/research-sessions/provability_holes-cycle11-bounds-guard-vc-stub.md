# Provability holes — cycle 11 (G-bnd guarded refinement VC stub)

**Run:** `proof_gap_researcher-2026-05-30-bounds-guard-vc` · **Date:** 2026-05-30  
**Goal:** `provability_holes` · **Focus:** **G-bnd**, **P-refine** · **PH-2e, PH-2f**  
**north_star_fit:** provable pillar — refinement bounds must appear in Lean VCs and/or codegen, not only C++ typecheck witnesses

## Executive summary

- **Index10** refinement params erase to plain **`Int`** in AutoVC; no `0 <= i < 10` Prop (`index_refinement.li`).
- **Guarded** call-site refinement (`if n >= 0: callee(n)`) also emits **`Prop := True`** — C++ branch facts witness away the predicate (`refinement_guard_ok.li`).
- Codegen uses **`getelementptr inbounds`** only; **`li_bounds_fail` declared but never called** (`emit.cpp:1275`, `896-922`).
- Raw **`int`** dynamic index still **rejected** at typecheck (E0201) — compile-time gate holds; Lean/codegen layers do not independently prove bounds.
- **`sqrt_open_bound`** retest: default **`lic build` fails** without `--allow-open-vc` (contract tier B intact).
- CI guard landed: **`bounds_refinement_lean_gap.sh`** wired into **`contracts_discharge_corpus.sh`**.

## Digest sections

### 1. Compiler / semantics gaps

| ID | Finding |
|----|---------|
| **G-bnd** | Release/debug codegen has **zero** runtime bounds checks; `li_bounds_fail` is dead import in LLVM IR. |
| **G-meta** | Deferred — no formal link between typecheck refinement discharge and Lean Props. |

### 2. Contract gaps

| ID | Finding |
|----|---------|
| **G-vc** | Proc-param refinement types not emitted as VCs; call-site refine VCs collapse to `True` when `check_refinement_argument` returns Satisfied (`vc_emit_lean.cpp:546-551`). |
| **P-refine** | `ensures result == a[i]` on `get` also stubs to `True` — index link not in Lean. |

### 3. Trusted surface

- No **`trusted.lean`** edits (policy).
- **`Discharge.lean`** has no index-bound lemmas for refinement params.

### 4. External trust boundaries

- **Human decision:** choose P-refine strategy — emit real Props vs MIR-linked bounds proof vs optional debug `li_bounds_fail` policy (`bounds-release-path.md draft in worktrees).

### 5. Evidence pack

| Item | Location |
|------|----------|
| Index specimen | `lic/li-tests/contracts_verify/index_refinement.li` |
| Guarded refine specimen | `lic/li-tests/contracts_verify/refinement_guard_ok.li` |
| Dynamic index reject | `lic/li-tests/cve_patterns/cwe787_dyn_index.li` → E0201 |
| VC erasure | `lic/build/generated/AutoVC.lean` — `vc_get_requires_0 (i : Int) : Prop := True` |
| Guarded stub | AutoVC — `vc_caller_guarded_call0_callee_refine_0 (n : Int) : Prop := True` |
| VC emit logic | `lic/compiler/verify/vc_emit_lean.cpp:546-551` |
| Refinement check | `lic/compiler/verify/call_requires.cpp:599-612` |
| Typecheck gate | `lic/compiler/types/typecheck.cpp:1203-1211` |
| Codegen (no runtime guard) | `lic/compiler/codegen/emit.cpp:916-922` |
| CI guard | `lic/li-tests/tooling/bounds_refinement_lean_gap.sh` |
| Register | `lic/docs/verification/provability-gaps.md` **G-bnd** |

**Repro:**

```bash
cd lic
./li-tests/tooling/bounds_refinement_lean_gap.sh
LIC=$(./scripts/resolve-lic.sh)
$LIC check li-tests/cve_patterns/cwe787_dyn_index.li 2>&1 | grep E0201
$LIC build li-tests/contracts_verify/sqrt_open_bound.li -o /dev/null  # exit 1 without --allow-open-vc
```

## Hypothesis outcomes

- **HYPOTHESIS: verified** — Index10 param erases to `Int` with `Prop := True` in AutoVC | evidence: `bounds_refinement_lean_gap.sh` + `AutoVC.lean:12`
- **HYPOTHESIS: verified** — Guarded `if n >= 0` call-site refine VC stubs to `True` | evidence: `refinement_guard_ok.li` AutoVC `vc_caller_guarded_call0_callee_refine_0`
- **HYPOTHESIS: verified** — Codegen never calls `li_bounds_fail`; only inbounds GEP | evidence: `build/last_emit.ll` — declare only, no `call void @li_bounds_fail`
- **HYPOTHESIS: falsified** — Lean emits `0 <= i < 10` for Index10 proc params | evidence: no such predicate in AutoVC after build
- **HYPOTHESIS: verified (retest)** — `sqrt_open_bound` blocks default build | evidence: `lic build sqrt_open_bound.li` exit 1, message "1 proof obligation(s) still need a Lean proof"
- **HYPOTHESIS: deferred** — Release builds omit bounds checks with proved refinement | evidence: `--release` IR policy not on main; see lic-vulkan worktree `check_release_bounds_ir.sh`

## Recommended issues/PRs

1. **lic:** `[G-bnd/P-refine] Emit refinement predicates to AutoVC for proc params and non-witnessed call sites` — labels: `provability`, `G-bnd`, `PH-2e`
2. **lic:** `[G-bnd] Add Discharge.lean index-bound lemmas; link ensures `result == a[i]`` — labels: `provability`, `G-vc`
3. **lic:** Retire `bounds_refinement_lean_gap.sh` when AutoVC carries real bounds Props and/or IR policy lands

## Deferred

- **G-net proxy seam** (cycle 10) — `seam_proxy_net_effect_gap.sh` on sibling branch
- **P-float sqrt_open_bound** — intentional open; needs Float.abs lemmas
- **Release-mode bounds IR audit** — port `check_release_bounds_ir.sh` from worktree when `--release` path stabilizes on main
