# G-par — AST `disjoint=` witnesses and race fixtures

## Summary

Tightens **G-par** parallel policy: `@parallel(disjoint=...)` and loop `requires` must use call-form disjoint proofs (or `disjoint_elem` / `disjoint_slice` proof-function refs); adds three `race_shared_memory` compile_fail specimens and updates the provability gap register.

## Agent continuation

1. **Read** [provability-gaps.md](../verification/provability-gaps.md) — **G-par** stays **Partial** (Lean **P-par** open).
2. **Run** `./li-tests/run_all.sh race_shared_memory` (9 compile_fail + 1 verify_ok).
3. **Next** — Lean discharge for `disjoint_*` (**7d-c**); overlap analysis beyond `grid[0][0]` constant pattern.
4. **Blocked on** **G-meta** / full MIR↔Lean semantics for iteration independence proofs.

## Changed

| Area | Paths |
|------|--------|
| **7b / 7d-c** | `compiler/types/policy_module.cpp` — E0350 weak loop `requires`; E0321 invalid `disjoint=` value |
| **Tests** | `li-tests/race_shared_memory/false_disjoint_requires_{true,bare_row}.li`, `false_disjoint_decorator_bare_row.li`; `manifest.toml` |
| **Docs** | `docs/verification/provability-gaps.md`, `proof-corpus-roadmap.md` (**P-par**) |

## Not changed

- **G-lean**, **G-vc**, **G-dec** Lean/MIR decorator elaboration.
- **G-meta**, **G-gpu**, **G-authz** (still Missing).
- `policy.cpp` typosquat / `Any` / historic string guards (unchanged).

## Breaking

N/A — rejects previously accepted bare `@parallel(disjoint=disjoint_row)` without a call.

## Security

**CWE-362** class: blocks weak parallel witnesses that looked like proofs (`requires true`, bare `disjoint_row` name).

## Performance

N/A — compile-time policy only.

## Downstream

- **li-cursor-agents** / **benchmarks** agent briefing unchanged until lic merge.
