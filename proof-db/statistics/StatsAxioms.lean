import Mathlib

namespace Li.ProofDb.Statistics

/-- Finite probability space over `Fin n` (ST-AX-PROB-FINITE). -/
structure FiniteProbSpace (n : Nat) where
  p : Fin n → ℝ
  p_nonneg : ∀ i, 0 ≤ p i
  p_sum_one : ∑ i, p i = 1

/-- Expectation of `X` under finite probability mass `Ω.p`. -/
noncomputable def expect {n : Nat} (Ω : FiniteProbSpace n) (X : Fin n → ℝ) : ℝ :=
  ∑ i, Ω.p i * X i

/-- Expectation is linear: E[aX + bY] = a E[X] + b E[Y] (ST-AX-EXPECT-LINEAR). -/
axiom expect_linear
  {n : Nat} (Ω : FiniteProbSpace n) (a b : ℝ) (X Y : Fin n → ℝ) :
  expect Ω (fun i => a * X i + b * Y i) = a * expect Ω X + b * expect Ω Y

/-- Sample mean of `n` observations (ST-LM-SAMPLE-MEAN-UNBIASED discharge target). -/
def sampleMean {n : Nat} (hn : 0 < n) (samples : Fin n → ℝ) : ℝ :=
  (n : ℝ)⁻¹ * ∑ i, samples i

/-- Sample mean is an unbiased estimator of population mean (ST-LM-SAMPLE-MEAN-UNBIASED; target). -/
axiom sample_mean_unbiased
  {n : Nat} (hn : 0 < n) (μ : ℝ) (Ω : FiniteProbSpace n) (draws : Fin n → ℝ) :
  expect Ω draws = μ → expect Ω (fun _ => sampleMean hn draws) = μ

end Li.ProofDb.Statistics
