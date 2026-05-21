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
| `sqrt_open_bound.li` | `abs(result² - x) < ε` | **Intentionally open** — `verify_open_ok` |
| `refinement_*_ok.li` | Refinement types at call/init | **Partial** — refinement VCs often `True`; user `ensures` may stay open |
| `refinement_guard_ok.li` | `if n >= 0` branch discharge | Same |

**Tooling entrypoints:**

```bash
./li-tests/tooling/contracts_discharge_corpus.sh
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

## Run results (2026-05-20, `main` after PR **#83** / **#88**)

| Suite | Result | Notes |
|-------|--------|-------|
| `run_all.sh contracts_verify` | **16 pass / 0 fail** | Includes `refinement_*_ok`; `sqrt_open_bound` = `verify_open_ok` |
| `contracts_discharge_corpus.sh` | **ok** | Trivial/const/index/caller-requires closed; `sqrt_open_bound` intentionally open |
| `run_httpd_config.sh` | **ok** | Python oracle + Li `match_routes.li` binary exit 0 |
| `contracts_verify_lean.sh` | **partial** | Needs Lean 4 + lake; may stop on specimens with open user `ensures` |
| `lake build` | **env-dependent** | `LI_BUILD_VERIFY_LEAN=1` on CI when lake present |

## Master-plan backlog (research: what to prove next)

Priority order aligned with [provability-gaps](provability-gaps.md) and **2e → 2f → 7d**:

| ID | Topic | Why unproven today | Suggested corpus |
|----|-------|-------------------|------------------|
| **P-refine** | Refinement types emit real Props | Call-site VCs stubbed `True`; user `ensures` still open | Extend `refinement_*` + Lean lemmas in `Discharge.lean` |
| **P-ensures-witness** | MIR-linked `ensures` for non-literal returns | `witnessed_ensures` partial | `caller()`, `use_positive.li`, physics smokes |
| **P-float** | `Float.abs`, sqrt error bounds | **G-vc** open (`sqrt_open_bound`) | `sqrt_open_bound.li` + `Li.Discharge` lemmas |
| **P-loop** | `while` invariant preservation | Few loop specimens | New `contracts_verify/loop_invariant_*.li` |
| **P-linalg** | Matrix/vector shapes (`@`, slices) | **G-math** partial | `math_linalg/*` + shape refinements |
| **P-par** | `parallel for` disjointness | **G-par** string heuristics only | Lean specs for `disjoint=` (7d-c) |
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
