# Provability holes — cycle 13 (G-vc vec3 opaque ensures)

**Run:** `proof_gap_researcher-2026-05-30-vec3-opaque-ensures` · **Date:** 2026-05-30  
**Goal:** `provability_holes` · **Focus:** **G-vc**, **P-linalg** · **PH-2e, PH-2f, PH-2i**  
**north_star_fit:** provable pillar — float linalg ensures must appear in Lean certificate

## Executive summary

- FieldAccess in `ensures` (`a.x * b.x + …`) is untranslatable → opaque comment → **`Prop := True`** default.
- **`return 0.0`** with dot-product ensures still **`lic build` succeeds** — certificate trivially closes.
- Body-local idents in ensures (`ax * bx + …`) match return via static witness — also **`True`** without param math.
- **`Vec3` → `Int`** erasure in AutoVC formals.
- CI guard **`vec3_dot_ensures_lean_gap.sh`** in **`contracts_discharge_corpus.sh`**.

## Digest sections

### 1. Compiler / semantics gaps

| ID | Finding |
|----|---------|
| **G-vc** | Opaque/untranslatable ensures default to `True` (`vc_emit_lean.cpp:343-372`) instead of open goal or build failure. |
| **G-math** | Float vec3 dot Props absent from Lean; P-linalg open per `provability-gaps.md`. |

### 2. Contract gaps

| ID | Finding |
|----|---------|
| **P-linalg** | `vec3_dot` ensures in `li-math` and `vec3_ops.li` certify without dot math in AutoVC. |
| **G-vc** | Static return witness (`expr_same_shape`) does not link fields to params. |

### 3. Trusted surface

- No **`trusted.lean`** edits.

### 4. External trust boundaries

- **Human RFC:** Lean `Vec3` record + field translation before closing float linalg corpus.

### 5. Evidence pack

| Command | Outcome |
|---------|---------|
| `./li-tests/tooling/vec3_dot_ensures_lean_gap.sh` | exit 0 |
| `lic build li-tests/contracts_verify/vec3_dot_wrong_return.li` | exit 0 (hole) |
| `lic check li-tests/contracts_verify/vec3_dot_wrong_return.li` | exit 0 |

**Key paths:** `vc_emit_lean.cpp:202-254`, `vc_emit_lean.cpp:343-372`, `vec3_dot_wrong_return.li`, `packages/li-math/src/lib.li:136`

## Hypothesis outcomes

- **HYPOTHESIS: verified** — FieldAccess ensures stub True | evidence: harness + AutoVC
- **HYPOTHESIS: verified** — Wrong return certifies | evidence: `lic build vec3_dot_wrong_return.li`
- **HYPOTHESIS: falsified** — Lean carries dot predicate | evidence: AutoVC grep
- **HYPOTHESIS: deferred** — Vec3 Lean typing | evidence: human RFC

## Recommended issues/PRs

1. `[G-vc/P-linalg] FieldAccess + Vec3 Lean type for ensures`
2. `[G-vc] Opaque ensures → open goal or fail, not default True`
3. Flip `vec3_dot_wrong_return.li` to `compile_fail` when fixed

## Deferred

- Method field requires (cycle 12), bounds refinement (cycle 11), sqrt_open_bound
