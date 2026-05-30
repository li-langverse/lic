import Mathlib
import Init.Data.Float

namespace Li.ProofDb.Numerics

/-- IEEE-style rounding stub (N-AX-FP-ROUND; G-hw float model). -/
axiom fp_round_axiom (exact result : Float) : Float

/-- Square-root accuracy stub — discharge target `Li.Discharge.sqrt_open_bound_spec`
    and specimen `li-tests/contracts_verify/sqrt_open_bound.li` (N-LM-SQRT-BOUND). -/
axiom sqrt_bound_axiom (x : Float) (hx : x ≥ (0 : Float)) : Prop

end Li.ProofDb.Numerics