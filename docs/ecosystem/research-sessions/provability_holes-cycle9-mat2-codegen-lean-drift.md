# provability_holes — cycle 9 (G-lean mat2_at2 codegen↔Lean drift)

**Run:** `proof_gap_researcher-2026-05-29-mat2-codegen-drift` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem, PH-2f, PH-2i, PH-7e

## Focus

**G-lean / G-math / G-meta:** `linalg_mat2_at2_float_closed.li` discharges via `Li.Discharge.mat2_at2_eval`, but MIR lowers `A @ B` to `ArrayMatMul2DF64` (`emit.cpp:1175-1195`) with no refinement proof linking codegen to the Lean eval function.

## Digest

### 1. Compiler / semantics gaps

- AutoVC ensures quantifies over `mat2_at2_eval A B`, not the MIR return of `return A @ B` (`build/generated/AutoVC.lean:14-15`).
- `_proved` theorem cites `mat2_at2_float_spec_proved`, which proves eval semantics only (`Discharge.lean:55-58`; `vc_emit_lean.cpp:355-410`).
- Codegen uses IKJ unrolled/looped matmul with optional FMA (`emit.cpp:1175-1195`, `253-278`) — no VC references `MirOp::ArrayMatMul2DF64`.

### 2. Contract gaps

- Closed certificate is **semantic** (Lean eval closed via `rfl`), not **operational** (MIR ≡ eval).
- `linalg_mat2_callproc_float_closed.li` uses entry-scalar `ensures` + static witness — same eval/MIR split for CallProc path.

### 3. Trusted surface

- No `trusted.lean` edits. `mat2_at2_eval` lives in `Discharge.lean` (proved surface, not axioms).

### 4. External trust boundaries

- Closing the gap requires a **G-meta / codegen witness** (MIR matmul refines `mat2_at2_eval`) or trusted axiom — human RFC if axiom route (`2026-05-22-mat2-float-spec-closed.md` §Blocked on).

### 5. Evidence pack

| G-* | Repro |
|-----|--------|
| **G-lean** / **G-math** | `bash li-tests/tooling/mat2_codegen_lean_drift.sh` → ok |
| **G-lean** | `build/generated/AutoVC.lean:14` — `mat2_at2_eval` in ensures |
| **G-meta** | `emit.cpp:1175` — `ArrayMatMul2DF64`; no AutoVC MIR link |
| **G-math** | `lic build li-tests/math_linalg/mat2_at2_golden_2x2.li --no-lean-verify && ./out` → exit 0 (runtime matches eval on fixture) |

### Hypothesis outcomes

- `HYPOTHESIS: verified — mat2_at2 closed VCs discharge eval not MIR return | evidence: AutoVC.lean:14-15; mat2_codegen_lean_drift.sh`
- `HYPOTHESIS: verified — certificate uses mat2_at2_float_spec_proved (eval rfl) not codegen witness | evidence: Discharge.lean:55-58; vc_emit_lean.cpp:406`
- `HYPOTHESIS: verified — ArrayMatMul2DF64 codegen has no Lean refinement link | evidence: emit.cpp:1175-1195; grep AutoVC (no mir_return_linked)`
- `HYPOTHESIS: falsified — runtime 2×2 @ diverges from mat2_at2_eval on golden fixture | evidence: mat2_at2_golden_2x2.li build+run exit 0`
- `HYPOTHESIS: deferred — prove MIR ArrayMatMul2DF64 refines mat2_at2_eval | evidence: G-meta Missing; P-linalg roadmap`

### Commands

```bash
lic=build/compiler/lic/lic
bash li-tests/tooling/mat2_codegen_lean_drift.sh
$lic build li-tests/contracts_verify/linalg_mat2_at2_float_closed.li -o /dev/null
grep mat2_at2_eval build/generated/AutoVC.lean
$lic build li-tests/math_linalg/mat2_at2_golden_2x2.li -o /tmp/g --no-lean-verify && /tmp/g
```
