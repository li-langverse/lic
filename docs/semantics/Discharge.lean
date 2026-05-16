/-!
# Discharge lemmas for generated AutoVC (Phase 2f partial)

Hand-written proofs for obligations that are definitionally true or axiomatized here.
Full float contract discharge remains open (**G-lean**).
-/
import Init.Data.Float
import Core

namespace Li.Discharge

open AutoVC.sqrt_pos

/-- Decreases obligations are literal naturals. -/
theorem vc_sqrt_pos_decreases_0_proved : vc_sqrt_pos_decreases_0 := rfl

end Li.Discharge
