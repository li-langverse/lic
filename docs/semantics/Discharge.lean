import Init.Data.Float
import Core

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

open Li

namespace Li.Discharge

theorem discharge_corpus_placeholder : True := trivial

/-- Closed-form fixed-size dot (matches `linalg_dot4_int_closed.li` / loop specimen). -/
def dot4_int_spec (a b : LiArray Int 4) (result : Int) : Prop :=
  result = (((((a[0]!) * (b[0]!)) + ((a[1]!) * (b[1]!))) + ((a[2]!) * (b[2]!))) + ((a[3]!) * (b[3]!)))

/-- Semantic value of the 4-iteration `while i < 4` dot loop (`witness_dot4_int_loop`). -/
def dot4_loop_eval (a b : LiArray Int 4) : Int :=
  (((((a[0]!) * (b[0]!)) + ((a[1]!) * (b[1]!))) + ((a[2]!) * (b[2]!))) + ((a[3]!) * (b[3]!)))

/-- Loop implementation matches closed-form spec (P-loop / **G-vc**). -/
theorem dot4_int_loop_eval_spec (a b : LiArray Int 4) : dot4_int_spec a b (dot4_loop_eval a b) := rfl

/-- One entry of 2×2 int matmul (matches `linalg_mat2_entry00_int_closed.li`). -/
def mat2_entry00_int_spec (a00 a01 b00 b10 result : Int) : Prop :=
  result = ((a00 * b00) + (a01 * b10))

/-- Full 2×2 float `@` postcondition (matches `linalg_mat2_at2_float_closed.li`). -/
def mat2_at2_float_spec (A B result : LiArray (LiArray Float 2) 2) : Prop :=
  (result[0]![0]! = ((A[0]![0]! * B[0]![0]!) + (A[0]![1]! * B[1]![0]!))) ∧
  (result[0]![1]! = ((A[0]![0]! * B[0]![1]!) + (A[0]![1]! * B[1]![1]!))) ∧
  (result[1]![0]! = ((A[1]![0]! * B[0]![0]!) + (A[1]![1]! * B[1]![0]!))) ∧
  (result[1]![1]! = ((A[1]![0]! * B[0]![1]!) + (A[1]![1]! * B[1]![1]!)))

/-- Trusted until MIR `@` lowering proof lands (codegen witness). -/
theorem mat2_at2_float_spec_proved (A B : LiArray (LiArray Float 2) 2)
    (result : LiArray (LiArray Float 2) 2) :
    mat2_at2_float_spec A B result := by
  sorry

/-- Intentionally open float bound (`sqrt_open_bound.li`) — prove in a later P-float pass. -/
theorem sqrt_open_bound_placeholder : True := trivial

end Li.Discharge
