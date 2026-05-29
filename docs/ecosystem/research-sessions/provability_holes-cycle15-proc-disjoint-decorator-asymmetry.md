# provability_holes — cycle 15 (G-par / G-dec proc inherit asymmetry)

**north_star_fit:** PH-7b, PH-7d-c — G-par / G-dec

## Finding

`check_stmt_parallel` and `check_stmt_parallel_capture` only inspect `Stmt::ParallelFor` (`policy_module.cpp:171-172`, `200-203`). Proc-level `@parallel(disjoint=disjoint_elem)` flows into `walk_stmts(..., proc_disjoint)` and satisfies nested **`parallel for`**, but nested **`@parallel for`** bypasses all parallel policy — including disjoint requirement and mut-capture guard.

## Evidence

```bash
bash li-tests/tooling/parallel_def_disjoint_inherit_decorator_gap.sh
lic check li-tests/decorators/parallel_def_disjoint_inherit_decorator_for.li   # exit 0 (hole)
lic check li-tests/decorators/parallel_def_disjoint_inherit.li                 # exit 0 (control)
```

- `HYPOTHESIS: verified — proc disjoint does not apply to @parallel for | evidence: policy_module.cpp:171-172; parallel_def_disjoint_inherit_decorator_for.li`
