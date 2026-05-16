/-!
# Li Core semantics (Phase 2f stub)

Replaces placeholder when typing rules and VC entailment are formalized.
See `docs/verification/provability-gaps.md` (**G-lean**, **G-trust**).
-/

namespace Li

/-- Build gate placeholder: Lake must compile before `lic build` accepts release. -/
theorem core_stub_ok : True := trivial

end Li

-- `build/generated/AutoVC.lean` (namespace `AutoVC`) imports this file on every `lic build`.
