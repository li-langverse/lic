# Proof database — Lean bridge (standard lemmas)

| Artifact | Role |
|----------|------|
| [`index.json`](index.json) | Five rows: textbook → `autovc_std_*` → `Li.ProofDB.*` |
| [`lean/ProofDB.lean`](lean/ProofDB.lean) | Proofs + one `sorry` (**P-float** triangle) |

```bash
cd docs/semantics && lake build ProofDB
```

**Gaps:** `std_triangle_ineq_scalar` is `sorry`; `autovc_std_*` not emitted by `lic build` yet.
