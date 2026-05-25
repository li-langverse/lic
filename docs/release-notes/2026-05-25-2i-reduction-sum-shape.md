# Release notes: 2026-05-25 — 2i reduction sum shape

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** Phase **2i**, **G-math**  
**Author:** agent

---

## Summary (one sentence)

`sum` on a non-array operand is rejected at typecheck with a manifest `compile_fail` specimen in `math_linalg/reductions/`.

## Agent continuation (required)

1. **Read:** `compiler/types/typecheck.cpp` (`sum` call), `li-tests/math_linalg/reductions/sum_non_array.li`, master plan **2i** row.
2. **Run:** `li-tests/run_all.sh math_linalg`.
3. **Then:** general NumPy rank broadcast; loop-dot Lean witness; tier-1 strict rows.
4. **Blocked on:** none for this slice.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `li-tests/math_linalg/reductions/sum_non_array.li` | `sum(1.0)` must fail typecheck | `compile_fail` in `manifest.toml` |
| Master plan / gaps | **2i** + **G-math** tracker | `2026-05-14-li-master-plan.md`, `provability-gaps.md` |

## Not changed (scope fence)

- Length-1 broadcast codegen (`broadcast_len1_*.li`).
- Lean `P-linalg` float `@` / `sqrt_open_bound` open specimens.
- Tier-1 perf strict gate.

## Breaking / Security / Performance / Downstream

N/A — static typecheck only.
