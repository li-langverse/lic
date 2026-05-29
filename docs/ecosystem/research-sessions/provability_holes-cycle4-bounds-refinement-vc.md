# provability_holes — cycle 4 (G-bnd refinement Lean stub)

**Run:** `proof_gap_researcher-2026-05-29-bounds-refinement` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem, PH-2e, PH-2f

## Focus

**G-bnd** + **P-refine:** refinement-typed array indices (`Index10`) pass typecheck and `verify_ok`, but Lean AutoVC and codegen do not carry bounds proofs or runtime guards.

## Digest

### 1. Compiler / semantics gaps

- Typecheck rejects plain `int` index (`cwe787_dyn_index.li` → E0201) — **compile-time fence** works for raw indices.
- Refinement param `i: Index10` lowers to plain `int` in MIR/codegen; `get` uses unchecked GEP (`emit.cpp:896-922`, disassembly at `0x1240`).
- `li_bounds_fail` is declared in `emit.cpp:1275` but **never called** from codegen (only linked from `li_rt`).

### 2. Contract gaps

- `index_refinement.li` → `build/generated/AutoVC.lean`: `vc_get_requires_0 (a : LiArray Int 10) (i : Int) : Prop := True` with `trivial` proof.
- Call-site refinement VCs also stubbed when witnessed: `vc_emit_lean.cpp:550-551` sets `prop = "True"` when `check_refinement_argument` is `Satisfied`.
- `refinement_call_ok.li`: `vc_caller_call0_callee_refine_0 := True` despite `NonNeg` callee param.

### 3. Trusted surface

- No `trusted.lean` edits (Net/IO axioms only, `trusted.lean:20-39`).

### 4. External trust boundaries

- Closing **P-refine** needs Lean lemmas in `Discharge.lean` (human-reviewed), not trusted axiom growth.

### 5. Evidence pack

| G-* | Repro |
|-----|--------|
| **G-bnd** | `lic build li-tests/contracts_verify/index_refinement.li` → AutoVC `True` requires; `objdump -d get` no `li_bounds_fail` call |
| **G-vc** / **P-refine** | `lic build li-tests/contracts_verify/refinement_call_ok.li` → `vc_caller_call0_callee_refine_0 := True` |
| **G-bnd** (negative) | `lic check li-tests/cve_patterns/cwe787_dyn_index.li` → E0201 |
| **G-lean** (retest) | `lic build li-tests/contracts_verify/sqrt_open_bound.li` → exit 1 without `--allow-open-vc` |

### Hypothesis outcomes

- `HYPOTHESIS: verified — refinement Index10 builds with AutoVC requires := True and i : Int | evidence: build/generated/AutoVC.lean:12-13`
- `HYPOTHESIS: verified — codegen get does not call li_bounds_fail | evidence: objdump get @ 0x1240; bounds_refinement_lean_gap.sh`
- `HYPOTHESIS: falsified — lic build emits li_bounds_fail on refinement-indexed access | evidence: emit.cpp only declares symbol`
- `HYPOTHESIS: falsified — dynamic int index compiles | evidence: cwe787_dyn_index.li E0201`
- `HYPOTHESIS: verified — witnessed call-site refinement VC is True stub | evidence: vc_emit_lean.cpp:550-551; refinement_call_ok AutoVC`
- `HYPOTHESIS: deferred — LLVM inbounds GEP prevents all OOB if refinement proof is wrong | evidence: no Lean bounds; FFI/unsound cast out of scope`

### Commands

```bash
lic=build/compiler/lic/lic
$lic check li-tests/contracts_verify/index_refinement.li          # exit 0
$lic build li-tests/contracts_verify/index_refinement.li -o /tmp/x # exit 0
bash li-tests/tooling/bounds_refinement_lean_gap.sh              # ok
$lic build li-tests/contracts_verify/sqrt_open_bound.li -o /dev/null  # exit 1
```
