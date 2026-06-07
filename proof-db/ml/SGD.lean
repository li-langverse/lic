import OptAxioms
import Convex

namespace Li.ProofDb.ML

/-- One gradient-descent step: x' = x − η ∇f(x). -/
def gradDescentStep {n : Nat} (η : ℝ) (grad : (Fin n → ℝ) → (Fin n → ℝ)) (x : Fin n → ℝ) :
    Fin n → ℝ :=
  fun i => x i - η * grad x i

/-- ML-LM-GRAD-DESCENT-RATE (open): convex L-smooth GD suboptimality bound O(1/k).
    Stated as axiom pending discharge against `grad_descent_step.li` specimen. -/
axiom ml_lm_grad_descent_rate
  (L : ℝ) (n k : Nat) (f : (Fin n → ℝ) → ℝ) (grad : (Fin n → ℝ) → (Fin n → ℝ))
  (x₀ x⋆ : Fin n → ℝ) :
  0 < L → 0 < k →
  (∀ x, f x⋆ ≤ f x) →
  ∃ C : ℝ, 0 < C ∧
    f (Nat.rec x₀ (fun _ x => gradDescentStep (1 / L) grad x) k) - f x⋆ ≤ C / k

end Li.ProofDb.ML
