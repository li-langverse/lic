import OptAxioms

namespace Li.ProofDb.ML

/-- Convex domain: closed under segment interpolation (stub definition). -/
def ConvexDomain {n : Nat} (S : Set (Fin n → ℝ)) : Prop :=
  ∀ x y : Fin n → ℝ, x ∈ S → y ∈ S → ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
    (fun i => (1 - t) * x i + t * y i) ∈ S

/-- ML-AX-CONVEX-DOM: training domain is convex (modeling axiom layer). -/
axiom convex_domain_axiom {n : Nat} (S : Set (Fin n → ℝ)) : ConvexDomain S → Prop

end Li.ProofDb.ML
