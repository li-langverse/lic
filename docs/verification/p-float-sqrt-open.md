# P-float: `sqrt_open_bound` status

## Specimen

`li-tests/contracts_verify/sqrt_open_bound.li` calls `li_rt_sqrt` with postcondition `abs(result * result - x) < 1e-12`.

## Policy

- **Build:** passes with `--allow-open-vc` (open VC on `abs` ensures).
- **Corpus:** `li-tests/tooling/contracts_discharge_corpus.sh` requires this goal to **stay open** until Float/libm lemmas land.
- **Lean:** `Li.Discharge.sqrt_open_bound_placeholder` is `trivial` — not a discharge of the runtime bound.

## Next (blocked)

Trusted libm error bound in `Discharge.lean`, or IEEE-754 + `li_rt_sqrt` contract axiom with human review — see **G-vc** / **P-float** in [provability-gaps.md](provability-gaps.md).
