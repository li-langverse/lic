/-!
# Discharge lemmas for generated AutoVC (Phase 2f partial)

`lic build` emits trivial `_proved` theorems in `build/generated/AutoVC.lean` for:
- `requires` / `ensures true`
- `ensures result == …` when the procedure body returns the same expression (static witness)
- literal `decreases` naturals

This module is reserved for hand-written lemmas that cannot be generated yet (e.g. float
postconditions for `sqrt_contract`). See **G-lean** in `docs/verification/provability-gaps.md`.
-/
import Init.Data.Float
import Core

namespace Li.Discharge

theorem discharge_corpus_placeholder : True := trivial

end Li.Discharge
