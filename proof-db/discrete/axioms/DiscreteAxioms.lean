import Mathlib

namespace Li.ProofDb.Discrete

/-- Int addition commutative (D-AX-INT-RING; see Mathlib.Data.Int.Basic). -/
axiom int_add_comm : ∀ a b : Int, a + b = b + a

/-- Int addition associative (D-AX-INT-RING). -/
axiom int_add_assoc : ∀ a b c : Int, (a + b) + c = a + (b + c)

/-- Int multiplication distributes over addition (D-AX-INT-RING). -/
axiom int_mul_distrib : ∀ a b c : Int, a * (b + c) = a * b + a * c

end Li.ProofDb.Discrete