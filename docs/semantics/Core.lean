import Init

/-!
# Li Core semantics (Phase 2f stub)

Replaces placeholder when typing rules and VC entailment are formalized.
See `docs/verification/provability-gaps.md` (**G-lean**, **G-trust**).

`LiArray α n` matches the compiler's fixed-size `array[n, α]` surface in `AutoVC.lean` (not
Lean's builtin `Array α`).
-/

namespace Li

/-- Build gate placeholder: Lake must compile before `lic build` accepts release. -/
theorem core_stub_ok : True := trivial

/-- Fixed-size array surface (`array[n, α]` in Li). Proof layer uses `Fin` indexing. -/
abbrev LiArray (α : Type) (n : Nat) := Fin n → α

instance {α : Type} {n : Nat} : GetElem (LiArray α n) Nat α fun _ i => i < n where
  getElem a i h := a ⟨i, h⟩

end Li

open Li

-- `build/generated/AutoVC.lean` (namespace `AutoVC`) imports this file on every `lic build`.
