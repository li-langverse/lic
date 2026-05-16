/-!
# Discharge lemmas for generated AutoVC (Phase 2f partial)

`vc_emit_lean.cpp` auto-emits `_proved` for `True` props, literal `decreases` (`rfl`),
and MIR-witnessed `ensures` (return shape matches). Add hand lemmas here only when Lean
needs trusted axioms from `trusted.lean` — not `sorry`.
-/
import Core

namespace Li.Discharge

end Li.Discharge
