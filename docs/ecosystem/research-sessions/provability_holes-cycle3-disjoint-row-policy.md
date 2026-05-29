# provability_holes — cycle 3 (G-par disjoint_row policy gap)

**Run:** `proof_gap_researcher-2026-05-29-disjoint-row` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem, PH-2e, PH-2f · **Focus:** `G-par` / `policy_module` soundness

## Hypothesis outcomes

| Outcome | Statement | Evidence |
|---------|-----------|----------|
| **verified** | `lic build` without `--allow-open-vc` fails on `sqrt_open_bound.li` open AutoVC | `lic build …/sqrt_open_bound.li` → exit 1, “1 proof obligation(s) still need a Lean proof” |
| **verified** | `LI_ALLOW_OPEN_VC=1` does not bypass open-VC gate | Same failure + warning at `main.cpp:243-244` |
| **verified** | `false_disjoint_proof.li` (`grid[0][0]`) is rejected with E0350 | `lic check` → `policy_module.cpp:183-188` |
| **verified** | `disjoint_row(i, grid)` + `grid[i][0]` compiles today (soundness hole) | `lic check li-tests/race_shared_memory/disjoint_row_writes_row_i.li` → exit 0 |
| **falsified** | Policy already rejects all `disjoint_row` + row-index writes | `false_disjoint_proof` fails but `disjoint_row_writes_row_i` passes |
| **deferred** | Lean proof of `disjoint_row` semantics | **G-par** still heuristic; no `Discharge.lean` lemma |

## Evidence pack

| Item | Location |
|------|----------|
| Constant-index guard | `compiler/types/policy_module.cpp:85-108`, `183-188` |
| Repro specimen | `li-tests/race_shared_memory/disjoint_row_writes_row_i.li` |
| CI guard (documents gap) | `li-tests/tooling/policy_disjoint_row_soundness.sh` |
| Register | `docs/verification/provability-gaps.md` **G-par** row |
| Contrast (caught) | `li-tests/race_shared_memory/false_disjoint_proof.li` |

## Commands

```bash
export LI_REPO_ROOT=/path/to/lic
LIC="$LI_REPO_ROOT/build/compiler/lic/lic"
$LIC check li-tests/race_shared_memory/disjoint_row_writes_row_i.li    # exit 0 — gap
$LIC check li-tests/race_shared_memory/false_disjoint_proof.li         # exit 1 — E0350
./li-tests/tooling/policy_disjoint_row_soundness.sh                    # documents gap
```

## Recommended follow-up

Extend `par_body_writes_constant_grid00` (or AST disjoint analysis) to reject writes to `grid[<loop-index>][…]` when contract is `disjoint_row(i, grid)`; flip manifest to `compile_fail` and remove `policy_disjoint_row_soundness.sh` guard.
