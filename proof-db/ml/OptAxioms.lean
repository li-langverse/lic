import Mathlib

namespace Li.ProofDb.ML

/-- Dot product on `Fin n → ℝ` (Euclidean inner product stub). -/
def inner {n : Nat} (u v : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, u i * v i

/-- L-smoothness (ML-AX-L-SMOOTH): ‖∇f(x) − ∇f(y)‖ ≤ L ‖x − y‖. -/
axiom l_smooth_axiom
  (L : ℝ) (n : Nat) (f : (Fin n → ℝ) → ℝ) (grad : (Fin n → ℝ) → (Fin n → ℝ)) :
  0 < L →
  ∀ x y : Fin n → ℝ, ‖grad x - grad y‖ ≤ L * ‖x - y‖

/-- μ-strong convexity: f(y) ≥ f(x) + ⟨∇f(x), y−x⟩ + (μ/2)‖y−x‖². -/
axiom mu_strong_convex_axiom
  (μ : ℝ) (n : Nat) (f : (Fin n → ℝ) → ℝ) (grad : (Fin n → ℝ) → (Fin n → ℝ)) :
  0 < μ →
  ∀ x y : Fin n → ℝ,
    f y ≥ f x + inner (grad x) (fun i => y i - x i) + (μ / 2) * ‖y - x‖ ^ 2

end Li.ProofDb.ML
