# Proof corpus and verification roadmap

**Audience:** agents extending **2e/2f**, reviewers judging “is `lic build` a proof certificate?”  
**Related:** [Provability gaps](provability-gaps.md) · [Proof database](proof-database.md) (`proof-db/manifest.toml` release pins) · [Contracts and proofs](../language/contracts-and-proofs.md) · [Master plan § 2e–2f](../superpowers/plans/2026-05-14-li-master-plan.md)

## Release regression manifest (v0)

| Artifact | Role |
|----------|------|
| [`proof-db/manifest.toml`](../../proof-db/manifest.toml) | `axioms/` + `lemmas/` rows with `release_pin` and `proof_status` |
| [`scripts/check-proof-db.sh`](../../scripts/check-proof-db.sh) | CI smoke — `PROOF_DB_SKIP=1` to skip locally |

A `proved` → `open` flip at a new `lic` release is usually a **proof tooling regression**, not invalid user Li. See [proof-database.md](proof-database.md).

## Proof database — classical math (`M-AX-*` / `M-LM-*`)

| Artifact | Role |
|----------|------|
| [`proof-database/entries/math-*.toml`](proof-database/entries/) | 9 axioms + 6 lemmas (5 proved, 1 discrepancy) |
| [`docs/semantics/proof-db/math/`](../semantics/proof-db/math/) | `lake build ProofDbMath` |
| [`proof-db/math/lemmas/`](../../proof-db/math/lemmas/) | `add_commutative.li` — **M-LM-FLOAT-ADD-COMM** (ℝ vs float / AutoVC) |

## Proof database — Lean bridge (legacy index)

| Artifact | Role |
|----------|------|
| [`proof-db/index.json`](../../proof-db/index.json) | Textbook → AutoVC name → Lean theorem → `proved` / `sorry` |
| [`proof-db/lean/ProofDB.lean`](../../proof-db/lean/ProofDB.lean) | `cd docs/semantics && lake build ProofDB` |

**Gaps:** `std_triangle_ineq_scalar` is `sorry` (**P-float**); `autovc_std_*` not emitted by `lic build` yet.

## Proof database — Lean bridge (standard lemmas)

| Artifact | Role |
|----------|------|
| [`proof-db/index.json`](../../proof-db/index.json) | Textbook → AutoVC name → Lean theorem → `proved` / `sorry` |
| [`proof-db/lean/ProofDB.lean`](../../proof-db/lean/ProofDB.lean) | `cd docs/semantics && lake build ProofDB` |

**Gaps:** `std_triangle_ineq_scalar` is `sorry` (**P-float**); `autovc_std_*` not emitted by `lic build` yet.

## What “testing proofs” means in this repo

| Layer | Command / script | Proves |
|-------|------------------|--------|
| **Static gate** | `lic build` (default on branch with 2f) | Parse, typecheck, borrow, emit MIR/LLVM; emit `AutoVC.lean`; **fail if open Prop goals** (`check-autovc-open-goals.sh`) |
| **VC inventory** | `lic verify <file>` | Counts `requires`/`ensures`/witnesses — **not** Lean kernel |
| **Lean discharge (real math)** | `li-tests/tooling/discharge_*_lean.sh`, `contracts_discharge_corpus.sh` | Regenerates AutoVC + **zero open goals**; optional `lake build` in `docs/semantics` |
| **Manifest smoke** | `./li-tests/run_all.sh contracts_verify` | **`verify_ok`** = strict `lic build` (open VC fails). **`prove_lean_ok`** = build + `check-autovc-open-goals.sh` + `lake build AutoVC` when Lean installed (else skip). |
| **Proof-db baseline** | `LI_PROOF_DB_STRICT=0 ./scripts/check-proof-db.sh` | JSONL pin vs `proof-db/baseline.jsonl` (`proved` / `placeholder` / `open`) |

!!! note "Manifest outcomes (G-test-verify)"
    Closed P-linalg / discharge specimens use **`prove_lean_ok`**. Intentional open VCs use **`verify_open_ok`**. **`verify_ok`** remains for specimens that compile under strict build but are not in the closed Lean corpus yet.

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
| `sqrt_open_bound.li` | `abs(result² - x) < ε` with `li_rt_sqrt` body | **Intentionally open** — `verify_open_ok` / `--allow-open-vc` |
| `refinement_*_ok.li` | Refinement types at call/init | **Partial** — refinement VCs often `True`; user `ensures` may stay open |
| `refinement_guard_ok.li` | `if n >= 0` branch discharge | Same |
| `linalg_dot4_int_closed.li` | Fixed 4-term int dot — return matches ensures | Fully discharged (`discharge_linalg_int_lean.sh`) |
| `linalg_sum4_int_closed.li` | Fixed 4-term int sum | Fully discharged |
| `linalg_mat2_entry00_int_closed.li` | Matmul (0,0) entry via scalars | Fully discharged |
| `linalg_dot4_int_loop_open.li` | Loop dot — `witness_dot4_int_loop` + `dot4_int_loop_eval_spec` | **Closed** — `verify_ok` |
| `linalg_norm4_int_closed.li` | Int norm (sum of squares) | Fully discharged |
| `linalg_axpy4_int_closed.li` | Scalar axpy `alpha*x+y` | Fully discharged |
| `linalg_dot4_float_closed.li` | Float dot via prelude | Fully discharged |

**Proof-db sweep reporter:**

```bash
./scripts/proof-db-report.sh --baseline proof-db/expected.json --run <sweep.jsonl>
```

See [proof-db/reporter.md](../../proof-db/reporter.md) for JSONL schema, failure modes, and `discrepancies.toml`.

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

## Run results (2026-05-25, `feat/g-items-wave`)

| Suite | Result | Notes |
|-------|--------|-------|
| `run_all.sh contracts_verify` | **26 pass / 0 fail** (14 `prove_lean_ok` + 12 `verify_ok`/`verify_open_ok`) | `prove_lean_ok` runs lake when elan on PATH |
| `contracts_discharge_corpus.sh` | **ok** | Trivial/const/index/caller-requires/**linalg closed**; `sqrt_open_bound` + loop dot intentionally open |
| `run_httpd_config.sh` | **ok** | Python oracle + Li `match_routes.li` binary exit 0 |
| `contracts_verify_lean.sh` | **partial** | Needs Lean 4 + lake; may stop on specimens with open user `ensures` |
| `lake build` | **default on `lic build`** | `--no-lean-verify` to skip; CI runs lake directly + tooling scripts |

## Master-plan backlog (research: what to prove next)

Priority order aligned with [provability-gaps](provability-gaps.md) and **2e → 2f → 7d**:

| ID | Topic | Why unproven today | Suggested corpus |
|----|-------|-------------------|------------------|
| **P-refine** | Refinement types emit real Props | Call-site VCs stubbed `True`; user `ensures` still open | Extend `refinement_*` + Lean lemmas in `Discharge.lean` |
| **P-ensures-witness** | MIR-linked `ensures` for non-literal returns | `witnessed_ensures` partial | `caller()`, `use_positive.li`, physics smokes |
| **P-float** | `Float.abs`, sqrt error bounds | **G-vc** open (`sqrt_open_bound`) | `sqrt_open_bound.li` + `Li.Discharge` lemmas |
| **P-loop** | `while` invariant preservation | Few loop specimens | New `contracts_verify/loop_invariant_*.li` |
| **P-linalg** | Matrix/vector shapes (`@`, slices) | **Partial** — closed dot/sum/matmul-entry/norm/axpy + loop witness. **Open:** float `vec3_dot` Props, 2D array CallProc | `contracts_verify/linalg_*`, `math_linalg/*` |
| **P-par** | `parallel for` disjointness | **G-par** string heuristics only | Lean specs for `disjoint=` (7d-c) |
| **P-dec** | Decorators never run at runtime | **G-dec** no MIR lowering | `decorator_exploits/` + elaboration proofs |
| **P-bnd** | Release builds omit `li_bounds_fail` | **G-bnd** | Refined indices + codegen proof |
| **P-http** | Parser/route config safety | Phase **H** | `httpd/*`, TOML desugar invariants |
| **P-narrow** | Width-narrowing / casts | **G-narrow** partial | Ariane-style `prove_reject` + proved narrowing |
| **P-meta** | Compiler ↔ `Core.lean` | **G-meta** research | Long-term; cite Dafny/CakeML VCG literature |
| **P-physics** | Classical mechanics + conservation axioms | Tier-2 `extern` **modeling_gap**; scalar lemmas in `Discharge.lean` | `docs/verification/proof-database/entries/physics-*.toml`, `proof-db/physics/`, tier-2 `three_body` / `nbody_gravity` / `md_lennard_jones` |

**Learned from (external):** Dafny `requires`/`ensures`/`decreases`; Lean 4 `mvcgen` / WP tactics; verified Dafny VCG (HOL4) for “what a finished pipeline proves.”

## Gap **G-test-verify** (manifest honesty)

| Today | Target |
|-------|--------|
| **`prove_lean_ok`** in `run_all.sh` + 14 closed `contracts_verify` rows | **Done** for split; lake step skips when elan absent |
| **`verify_ok`** = strict `lic build` (default open-VC gate) | Same as planned `prove_compile_ok` name |
| Remaining corpus on `verify_ok` | Retag when `discharge_*_lean.sh` covers them |
| CI without Lean | `prove_lean_ok` → skip (not fail) — install elan in semantics job for full gate |

## Agent checklist (before claiming “proofs pass”)

1. Run `contracts_discharge_corpus.sh` and `run_all.sh contracts_verify`.
2. If Lean installed: `contracts_verify_lean.sh` and `LI_BUILD_VERIFY_LEAN=1 lic build …`.
3. Inspect `build/generated/AutoVC.lean` for `Prop :=` lines that are not `True` and lack `_proved`.
4. Update this file and **G-*** rows when adding specimens.
