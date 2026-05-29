# provability_holes — cycle 7 (G-par disjoint_elem constant index)

**Run:** `proof_gap_researcher-2026-05-29-disjoint-elem-constant` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem, PH-2e, PH-2f, PH-7b

## Focus

**G-par:** `policy_module.cpp` rejects `disjoint_row` + constant `grid[0][0]` writes but does **not** apply the same check to `disjoint_elem` + `buf[0]`.

## Digest

### 1. Compiler / semantics gaps

- `par_body_writes_constant_grid00` runs only when `contract_uses_disjoint_row` (`policy_module.cpp:183-188`); no symmetric path for `disjoint_elem`.
- `false_disjoint_elem_constant_index.li` (`buf[0] = …` under `disjoint_elem(i, buf)`) **passes** `lic check` (exit 0).
- Control `false_disjoint_proof.li` (`grid[0][0]` under `disjoint_row`) **fails** E0350 (exit 1).

### 2. Contract gaps

- Proof builtins are syntax-checked in typecheck; policy only pattern-matches one false-proof shape for rows.
- `good_disjoint_elem_per_index.li` (`buf[i]`) and `good_disjoint_parallel.li` (`grid[i][0]`) correctly pass — per-iteration indices are sound.

### 3. Trusted surface

- No `trusted.lean` edits.

### 4. External trust boundaries

- Fix is AST policy in `policy_module.cpp` (extend constant-index detection for `disjoint_elem`); Lean **P-par** discharge remains deferred.

### 5. Evidence pack

| G-* | Repro |
|-----|--------|
| **G-par** | `bash li-tests/tooling/policy_disjoint_elem_soundness.sh` → ok |
| **G-par** | `lic check li-tests/race_shared_memory/false_disjoint_elem_constant_index.li` → exit 0 (hole) |
| **G-par** | `lic check li-tests/race_shared_memory/false_disjoint_proof.li` → exit 1 E0350 |
| **G-par** | `lic check li-tests/race_shared_memory/good_disjoint_elem_per_index.li` → exit 0 |

### Hypothesis outcomes

- `HYPOTHESIS: verified — disjoint_elem + buf[0] passes lic check while row grid[0][0] is rejected | evidence: policy_disjoint_elem_soundness.sh; false_disjoint_elem_constant_index.li exit 0`
- `HYPOTHESIS: verified — root cause is disjoint_row-only guard in policy_module | evidence: policy_module.cpp:71-108, 183-188`
- `HYPOTHESIS: verified — per-index buf[i] / grid[i][0] under correct disjoint contract passes | evidence: good_disjoint_elem_per_index.li; good_disjoint_parallel.li exit 0`
- `HYPOTHESIS: falsified — grid[i][0] under disjoint_row is an unsound hole (cycle 3 retest) | evidence: good_disjoint_parallel.li verify_ok; disjoint_row means row i`
- `HYPOTHESIS: deferred — Lean kernel discharge for disjoint_elem | evidence: P-par open in proof-corpus-roadmap`

### Commands

```bash
lic=build/compiler/lic/lic
bash li-tests/tooling/policy_disjoint_elem_soundness.sh
$lic check li-tests/race_shared_memory/false_disjoint_elem_constant_index.li   # exit 0 (gap)
$lic check li-tests/race_shared_memory/false_disjoint_proof.li                 # exit 1
$lic check li-tests/race_shared_memory/good_disjoint_elem_per_index.li         # exit 0
```
