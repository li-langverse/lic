import Lake
open Lake DSL

package liSemantics where
  leanOptions := #[⟨`autoImplicit, false⟩]

@[default_target]
lean_lib LiSemantics where
  roots := #[`Core]

lean_lib AutoVC where
  srcDir := "../../build/generated"
  roots := #[`AutoVC]

lean_lib Discharge where
  roots := #[`Discharge]
  deps := #[`LiSemantics, `AutoVC]

/-- Classical math M-AX-* / M-LM-* (`proof-db/math/axioms/`). -/
lean_lib ProofDbMath where
  srcDir := "../../proof-db/math/axioms"
  roots := #[`MathAxioms, `MathLemmas]
  deps := #[`LiSemantics]
