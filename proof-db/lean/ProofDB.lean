import Core

/-!
# Proof database — compiler release gate slice

Registry: `proof-db/index.json`. Baseline: `proof-db/baseline.jsonl` via `scripts/export-proof-db.sh`.
-/

namespace Li.ProofDB

theorem std_add_comm_int (a b : Int) : a + b = b + a :=
  Int.add_comm a b

theorem std_mul_assoc_int (a b c : Int) : (a * b) * c = a * (b * c) :=
  Int.mul_assoc a b c

theorem std_triangle_ineq_float_scalar (a b : Float) :
    Float.abs (a + b) ≤ Float.abs a + Float.abs b := by
  sorry

/-- Release gate placeholder row (baseline `placeholder` status). -/
theorem proof_db_release_gate_stub : True := trivial

end Li.ProofDB
