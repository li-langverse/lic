# provability_holes — cycle 8 (G-par / G-dec decorator-for policy bypass)

**Run:** `proof_gap_researcher-2026-05-29-decorator-for-policy` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem, PH-2e, PH-2f, PH-7b, PH-7d

## Focus

**G-par / G-dec:** `check_stmt_parallel` and `check_stmt_parallel_capture` return early unless `stmt.kind == ParallelFor` (`policy_module.cpp:171-172`, `200-203`). `@parallel(disjoint=disjoint_elem)` on a plain `for` therefore bypasses **mut capture** and **borrow mut** guards that `parallel for` enforces.

## Digest

### 1. Compiler / semantics gaps

- Decorated `for` is `Stmt::For`, not `ParallelFor` (`parser.cpp:843-846`; cycle 5).
- Policy walks `for_body` but parallel-specific checks never run on `For` (`policy_module.cpp:168-213`, `226`).
- `@parallel` on `for` still does not lower to OpenMP (cycle 5); this cycle adds **policy** bypass even when users adopt decorator syntax with `disjoint=`.

### 2. Contract gaps

- `parallel_decorator_mut_capture_outer.li` assigns to outer `counter` — **passes** `lic check` (exit 0).
- `parallel_decorator_borrow_mut_across_iters.li` uses `borrow mut` in loop body — **passes** `lic check` (exit 0).
- Controls `mut_capture_no_sync.li` and `borrow_mut_across_iters.li` (**`parallel for`**) fail E0320/E0350 (exit 1).

### 3. Trusted surface

- No `trusted.lean` edits.

### 4. External trust boundaries

- Fix: extend policy to walk `@parallel` on `Stmt::For` (or elaborate to `ParallelFor` per 7d-b); Lean **P-par** discharge remains deferred.

### 5. Evidence pack

| G-* | Repro |
|-----|--------|
| **G-par** / **G-dec** | `bash li-tests/tooling/parallel_decorator_policy_capture_gap.sh` → ok |
| **G-par** | `lic check li-tests/decorators/parallel_decorator_mut_capture_outer.li` → exit 0 (hole) |
| **G-par** | `lic check li-tests/race_shared_memory/mut_capture_no_sync.li` → exit 1 (Sync / disjoint) |
| **G-par** | `lic check li-tests/decorators/parallel_decorator_borrow_mut_across_iters.li` → exit 0 (hole) |
| **G-par** | `lic check li-tests/race_shared_memory/borrow_mut_across_iters.li` → exit 1 (borrow) |

### Hypothesis outcomes

- `HYPOTHESIS: verified — @parallel for with outer var mutation passes lic check | evidence: parallel_decorator_mut_capture_outer.li exit 0; parallel_decorator_policy_capture_gap.sh`
- `HYPOTHESIS: verified — @parallel for with borrow mut in body passes lic check | evidence: parallel_decorator_borrow_mut_across_iters.li exit 0`
- `HYPOTHESIS: verified — parallel for keyword still rejects same patterns | evidence: mut_capture_no_sync.li; borrow_mut_across_iters.li exit 1`
- `HYPOTHESIS: verified — root cause is ParallelFor-only guards in policy_module | evidence: policy_module.cpp:171-172, 200-203`
- `HYPOTHESIS: falsified — decorated for inherits parallel for policy checks | evidence: lic check exit 0 on hole specimens`
- `HYPOTHESIS: deferred — Lean discharge for decorated loops | evidence: P-par open; elaboration 7d-b`

### Commands

```bash
lic=build/compiler/lic/lic  # or scripts/resolve-lic.sh
bash li-tests/tooling/parallel_decorator_policy_capture_gap.sh
$lic check li-tests/decorators/parallel_decorator_mut_capture_outer.li       # exit 0
$lic check li-tests/decorators/parallel_decorator_borrow_mut_across_iters.li  # exit 0
$lic check li-tests/race_shared_memory/mut_capture_no_sync.li                 # exit 1
$lic check li-tests/race_shared_memory/borrow_mut_across_iters.li              # exit 1
```
