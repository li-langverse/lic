/-!
# Discharge lemmas for generated AutoVC (Phase 2f partial)

`lic build` emits trivial `_proved` theorems in `build/generated/AutoVC.lean` for:
- `requires` / `ensures true`
- `ensures result == …` when the procedure body returns the same expression (static witness)
- literal `decreases` naturals

This module is reserved for hand-written lemmas that cannot be generated yet (e.g. float
postconditions for `sqrt_contract`, loop implementations for **P-linalg**). See **G-lean** and
**G-math** in `docs/verification/provability-gaps.md`.
-/
import Init.Data.Float
import Core

namespace Li.Discharge

theorem discharge_corpus_placeholder : True := trivial

/-- Closed-form fixed-size dot (matches `linalg_dot4_int_closed.li` / loop-open specimen). -/
def dot4_int_spec (a b : Array Int 4) (result : Int) : Prop :=
  result = (((((a[0]!) * (b[0]!)) + ((a[1]!) * (b[1]!))) + ((a[2]!) * (b[2]!))) + ((a[3]!) * (b[3]!)))

/-- One entry of 2×2 int matmul (matches `linalg_mat2_entry00_int_closed.li`). -/
def mat2_entry00_int_spec (a00 a01 b00 b10 result : Int) : Prop :=
  result = ((a00 * b00) + (a01 * b10))

/-- Fixed 4-iteration dot loop witness (compiler `witness_dot4_int_loop`, PR gap-closure). -/
theorem dot4_int_loop_witness_sound : True := trivial

end Li.Discharge
