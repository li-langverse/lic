# Proof corpus and verification roadmap

**Audience:** agents extending **2e/2f**, reviewers judging “is `lic build` a proof certificate?”  
**Related:** [Provability gaps](provability-gaps.md) · [Contracts and proofs](../language/contracts-and-proofs.md) · [Master plan § 2e–2f](../superpowers/plans/2026-05-14-li-master-plan.md)

## What “testing proofs” means in this repo

| Layer | Command / script | Proves |
|-------|------------------|--------|
| **Static gate** | `lic build` (default on branch with 2f) | Parse, typecheck, borrow, emit MIR/LLVM; emit `AutoVC.lean`; **fail if open Prop goals** (`check-autovc-open-goals.sh`) |
| **VC inventory** | `lic verify <file>` | Counts `requires`/`ensures`/witnesses — **not** Lean kernel |
| **Lean discharge (real math)** | `li-tests/tooling/discharge_*_lean.sh`, `contracts_discharge_corpus.sh` | Regenerates AutoVC + **zero open goals**; optional `lake build` in `docs/semantics` |
| **Manifest smoke** | `./li-tests/run_all.sh contracts_verify` | Today: **`verify_ok` = `lic build` only** — see gap **G-test-verify** below |

!!! warning "Do not equate `verify_ok` with Lean QED"
    Until manifest outcomes are split (`prove_compile_ok` vs `prove_lean_ok`), passing `run_all.sh contracts_verify` only means **build + autovc script**, not full kernel verification.

## Corpus library (positives)

| File | Intent | Lean / AutoVC |
|------|--------|----------------|
| `discharge_trivial.li` | Literal `decreases`, `ensures result == 0` | Fully discharged (`discharge_trivial_lean.sh`) |
| `discharge_const.li` | Const-return witnesses | Discharged (`discharge_const_lean.sh`) |
| `caller_requires_ok.li` | Call-site `requires` + literal arg | Discharged (`discharge_caller_requires_lean.sh`) |
| `caller_requires_local_ok.li` | Const-local discharge | Discharged |
| `method_call_requires_ok.li` | Method call-site `requires` on `Type_method` | Build + autovc (2j-f) |
| `extern_call_requires_ok.li` | Imported callee `requires` | Discharged |
| `index_refinement.li` | Index refinement type + array access | Build + autovc check in corpus |
| `sqrt_contract.li` | Float `requires`/`ensures` (toy `sqrt`) | Emits real Props; float goals may stay open |
| `sqrt_open_bound.li` | `abs(result² - x) < ε` with `li_rt_sqrt` body | **Intentionally open** — `verify_open_ok` / `--allow-open-vc` — see [sqrt-open-bound](sqrt-open-bound.md) |
| `refinement_*_ok.li` | Refinement types at call/init | **Partial** — refinement VCs often `True`; user `ensures` may stay open |
| `refinement_guard_ok.li` | `if n >= 0` branch discharge | Same |
| `linalg_dot4_int_closed.li` | Fixed 4-term int dot — return matches ensures | Fully discharged (`discharge_linalg_int_lean.sh`) |
| `linalg_sum4_int_closed.li` | Fixed 4-term int sum | Fully discharged |
| `linalg_mat2_entry00_int_closed.li` | Matmul (0,0) entry via scalars | Fully discharged |
| `linalg_dot4_int_loop_open.li` | Loop dot — `witness_dot4_int_loop` + `dot4_int_loop_eval_spec` | **Closed** — `verify_ok` |
| `linalg_norm4_int_closed.li` | Int norm (sum of squares) | Fully discharged |
| `linalg_axpy4_int_closed.li` | Scalar axpy `alpha*x+y` | Fully discharged |
| `linalg_dot4_float_closed.li` | Float dot via prelude | Fully discharged |

**Tooling entrypoints:**

```bash
./li-tests/tooling/contracts_discharge_corpus.sh
./li-tests/tooling/discharge_linalg_int_lean.sh   # P-linalg closed specimens
./li-tests/tooling/contracts_verify_lean.sh   # needs Lean 4 + lake for full 2f
./li-tests/run_all.sh contracts_verify
```

## Corpus library (negatives)

| File | Expected | Mechanism |
|------|----------|-----------|
| `caller_requires_fail.li` | `compile_fail` + **E0304** | `callee(-1)` vs `requires x >= 0` |
| `refinement_call_fail.li` | `compile_fail` + **E0305** | Non-literal outside refinement |
| `refinement_init_fail.li` | `compile_fail` + **E0305** | Bad `var` init |
| `prove_reject/uses_any.li` | reject | Policy |
| `prove_reject/uses_sorry.li` | reject | Policy |
| `prove_reject/missing_contracts.li` | reject | Grammar |
| `prove_reject/missing_decreases.li` | reject | Grammar |
| `prove_reject/bare_cast.li` | reject | **G-narrow** |
| `prove_reject/weak_ensures_true.li` | reject | **E0303** |
| `cve_patterns/cwe676_extern_no_contract.li` | reject | Extern must have contracts |

## Run results (2026-05-22, plan loop `wave-a-2f-vc-corpus`)

| Suite | Result | Notes |
|-------|--------|-------|
| `run_all.sh contracts_verify` | **26 pass / 0 fail** | Includes **P-linalg** closed + loop dot `verify_ok` |
| `contracts_discharge_corpus.sh` | **ok** | Trivial/const/index/**linalg closed**; `sqrt_open_bound` **must stay open** (`vc_sqrt_open_ensures_0`) |
| `contracts_verify_lean.sh` | **ok** | Runs corpus first, then `sqrt_contract` + caller-requires discharge + lake |
| `run_httpd_config.sh` | **ok** | Python oracle + Li `match_routes.li` binary exit 0 |
| `sqrt_open_bound` default build | **fail (expected)** | Documented in [sqrt-open-bound](sqrt-open-bound.md); P-float closure deferred |
| `lake build` | **default on `lic build`** | `--no-lean-verify` to skip; CI + `compiler-studio-plan-gates.sh` run corpus scripts |

## Master-plan backlog (research: what to prove next)

Priority order aligned with [provability-gaps](provability-gaps.md) and **2e → 2f → 7d**:

| ID | Topic | Why unproven today | Suggested corpus |
|----|-------|-------------------|------------------|
| **P-refine** | Refinement types emit real Props | Call-site VCs stubbed `True`; user `ensures` still open | Extend `refinement_*` + Lean lemmas in `Discharge.lean` |
| **P-ensures-witness** | MIR-linked `ensures` for non-literal returns | `witnessed_ensures` partial | `caller()`, `use_positive.li`, physics smokes |
| **P-float** | `Float.abs`, sqrt error bounds | **G-vc** open (`sqrt_open_bound`) | `sqrt_open_bound.li` + `Li.Discharge` lemmas |
| **P-loop** | `while` invariant preservation | Few loop specimens | New `contracts_verify/loop_invariant_*.li` |
| **P-linalg** | Matrix/vector shapes (`@`, slices) | **Partial** — closed dot/sum/matmul-entry/norm/axpy + loop witness. **Open:** float `vec3_dot` Props, 2D array CallProc | `contracts_verify/linalg_*`, `math_linalg/*` |
| **P-par** | `parallel for` disjointness | **G-par** AST policy only (`policy_module`, `policy.cpp` exploits); no kernel discharge | **Lean G-par roadmap (wave-a-7d, disjoint from 7d `@vectorized`):** (1) `Li.Parallel.Disjoint` — interpret `disjoint_elem` / `disjoint_row` / proc `@parallel(disjoint=…)` as structured `Prop`, not strings; (2) `contracts_verify/par_disjoint_*.li` — closed 1D index + tile specimens mirroring `parallel_with_disjoint.li` / `parallel_def_disjoint_inherit.li`; (3) wire `ParallelFor` MIR indices into AutoVC (`_par*` obligations today typecheck only); (4) reject false `disjoint_row` + mut-capture in Lean, not only AST; (5) **open:** cross-TU / nested `parallel for` — after (1)–(3). **Not in 7d vectorized slice:** SIMD decorators (**P-dec**). |
| **P-dec** | Decorators never run at runtime | **G-dec** no MIR lowering | `decorator_exploits/` + elaboration proofs |
| **P-bnd** | Release builds omit `li_bounds_fail` | **G-bnd** | Refined indices + codegen proof |
| **P-http** | Parser/route config safety | Phase **H** | `httpd/*`, TOML desugar invariants |
| **P-narrow** | Width-narrowing / casts | **G-narrow** partial | Ariane-style `prove_reject` + proved narrowing |
| **P-meta** | Compiler ↔ `Core.lean` | **G-meta** research | Long-term; cite Dafny/CakeML VCG literature |

**Learned from (external):** Dafny `requires`/`ensures`/`decreases`; Lean 4 `mvcgen` / WP tactics; verified Dafny VCG (HOL4) for “what a finished pipeline proves.”

## Gap **G-test-verify** (manifest honesty)

| Today | Target |
|-------|--------|
| `verify_ok` runs `lic build` only | `prove_compile_ok` + `prove_lean_ok` (lake + zero open goals) |
| Mixed open-VC policy on branch | Document per-file: closed / open-intentional / lean-handwritten |

## Agent checklist (before claiming “proofs pass”)

1. Run `contracts_discharge_corpus.sh` and `run_all.sh contracts_verify`.
2. If Lean installed: `contracts_verify_lean.sh` and `LI_BUILD_VERIFY_LEAN=1 lic build …`.
3. Inspect `build/generated/AutoVC.lean` for `Prop :=` lines that are not `True` and lack `_proved`.
4. Update this file and **G-*** rows when adding specimens.
