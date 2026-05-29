# provability_holes — cycle 5 (G-dec @parallel on plain `for`)

**Run:** `proof_gap_researcher-2026-05-29-parallel-decorator-for` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem, PH-2e, PH-2f, PH-7d

## Focus

**G-dec / 7d-b:** `@parallel(disjoint=…)` on a plain `for` loop is accepted by the compiler but does **not** elaborate to `ParallelFor` / `OmpParallelFor` (unlike `parallel for` or `@vectorized` on `for`).

## Digest

### 1. Compiler / semantics gaps

- Parser maps `@parallel` + `parallel for` → `Stmt::ParallelFor` (`parser.cpp:787-841`); `@parallel` + `for` → `Stmt::For` with decorators (`parser.cpp:843-846`).
- MIR lowering emits `OmpParallelFor` only for `ParallelFor` (`lower.cpp:1941-1969`); `For` ignores `@parallel` and may only wrap `@vectorized` with `ArraySimdScope` (`lower.cpp:1994-2040`).
- Evidence: `parallel_float_zero.li` → `__li_par_main_0` + `li_omp_parallel_for_i64` call in `li_user_main`; `parallel_decorator_on_for_serial.li` → **no** `__li_par_*`, no omp call in `li_user_main` (`parallel_decorator_for_elaboration_gap.sh`).

### 2. Contract gaps

- `check_stmt_parallel` returns early unless `stmt.kind == ParallelFor` (`policy_module.cpp:171-172`) — decorated `for` never gets disjoint-body policy.
- `@parallel` on `for` **without** `disjoint=` passes `lic check` (`parallel_decorator_on_for_no_disjoint.li` exit 0); proc-level `@parallel` still requires `disjoint=` (`policy_module.cpp:236-240`).

### 3. Trusted surface

- No `trusted.lean` edits.

### 4. External trust boundaries

- Elaboration fix is compiler-only (7d-b); Lean `disjoint_*` lemmas for decorated loops remain **P-par** (deferred).

### 5. Evidence pack

| G-* | Repro |
|-----|--------|
| **G-dec** | `bash li-tests/tooling/parallel_decorator_for_elaboration_gap.sh` → ok |
| **G-dec** | `lic check li-tests/decorators/parallel_decorator_on_for_serial.li` → exit 0 |
| **G-dec** (policy) | `lic check li-tests/decorators/parallel_decorator_on_for_no_disjoint.li` → exit 0 |
| **G-dec** (contrast) | `nm` on `parallel_float_zero` build → `__li_par_main_0` |

### Hypothesis outcomes

- `HYPOTHESIS: verified — @parallel on plain for does not emit __li_par_* worker | evidence: parallel_decorator_for_elaboration_gap.sh; lower.cpp For vs ParallelFor`
- `HYPOTHESIS: verified — parallel for keyword emits OpenMP wrapper | evidence: parallel_float_zero.li objdump li_user_main → li_omp_parallel_for_i64`
- `HYPOTHESIS: verified — @parallel on for without disjoint= passes lic check | evidence: parallel_decorator_on_for_no_disjoint.li exit 0`
- `HYPOTHESIS: falsified — @parallel on for lowers like parallel for keyword | evidence: nm/objdump contrast above`
- `HYPOTHESIS: deferred — decorator list on For is dead metadata harmless | evidence: users may believe HPC path runs; handbook 7d-b open`

### Commands

```bash
lic=build/compiler/lic/lic  # or scripts/resolve-lic.sh
$lic check li-tests/decorators/parallel_decorator_on_for_serial.li          # exit 0
$lic check li-tests/decorators/parallel_decorator_on_for_no_disjoint.li       # exit 0
bash li-tests/tooling/parallel_decorator_for_elaboration_gap.sh              # ok
```
