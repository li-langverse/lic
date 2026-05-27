# 2i plan tracker: norm reduction shape compile_fail

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Branch:** `feat/gap-close-tracker`  
**PH / REQ:** Phase **2i**, **G-math** (master plan tracker)

---

## Summary

Adds `norm_non_array.li` so scalar `norm(1.0)` is rejected at typecheck like `sum_non_array.li`, and syncs master plan / provability-gaps **2i** tracker rows.

## Agent continuation

1. **Read:** `docs/superpowers/plans/2026-05-14-li-master-plan.md` (Phase **2i**), `docs/verification/provability-gaps.md` (**G-math**).
2. **Run:** `./scripts/build.sh && ./li-tests/run_all.sh math_linalg`.
3. **Then:** general NumPy rank broadcast (separate PR); **7e** tier-1 strict on refreshed `latest.csv`; **8p** wall-time SLO logging.
4. **Blocked on:** none for this slice.

## Changed

| Area | What | Evidence |
|------|------|----------|
| **2i / G-math** | `norm_non_array.li` compile_fail | `li-tests/math_linalg/reductions/norm_non_array.li` |
| Manifest | New row + `expected_substr` | `li-tests/manifest.toml` |
| Tracker | Master plan **2i** + **G-math** closed slice | `docs/superpowers/plans/2026-05-14-li-master-plan.md`, `docs/verification/provability-gaps.md` |

## Not changed

- Compiler `norm` implementation (already rejects non-array in `typecheck.cpp`).
- Phases **7d**, **7e**, **8p**, **Vision-LLM** code paths.
- Tier-1 perf CSV / `LI_TIER1_PERF_STRICT`.
- P-linalg loop-dot witness or float `@` Props.

## Breaking changes

None.

## Security

N/A — typecheck specimen only.

## Performance

N/A.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis | N/A |

## CHANGELOG entry

```markdown
- **2i / G-math (tracker):** `norm_non_array.li` compile_fail for scalar `norm` — `docs/release-notes/2026-05-25-2i-norm-plan-tracker.md`.
```
