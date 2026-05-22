# `sqrt_open_bound` — intentional open VC (P-float)

**Specimen:** `li-tests/contracts_verify/sqrt_open_bound.li`  
**Manifest:** `verify_open_ok` (build only with `--allow-open-vc`)  
**Related:** [Proof corpus roadmap](proof-corpus-roadmap.md) · [Provability gaps — G-vc / P-float](provability-gaps.md)

## Status (Wave A 2f)

| Check | Result |
|-------|--------|
| `lic build` (default) | **Fails** — open Prop `vc_sqrt_open_ensures_0` |
| `lic build --allow-open-vc` | **Passes** — codegen + LLVM; Lean optional |
| `contracts_discharge_corpus.sh` | **Passes** — asserts goal stays **open** after allow-open build |
| Lean kernel discharge | **Deferred** — no `vc_sqrt_open_ensures_0_proved` until P-float lemmas exist |

**Decision (2026-05-22):** Do **not** stub the `ensures` to `True` or weaken `E0303`. Keep the real postcondition `abs(result * result - x) < 1e-12` and document closure criteria below.

## What the VC encodes

```li
def sqrt_open(x: float) -> float
  requires x >= 0.0
  ensures abs(result * result - x) < 1e-12
=
  return li_rt_sqrt(x)
```

- **Callee:** `li_rt_sqrt` is `extern` with `ensures true` (trusted runtime; no error bound in the contract yet).
- **Emitted AutoVC:** `vc_sqrt_open_ensures_0` relates `result`, `x`, and `abs(...)` — not discharged by static witness (non-literal return, float `abs`).

## Closure criteria (P-float backlog)

To move this specimen from `verify_open_ok` → `verify_ok` with default `lic build`:

1. **Runtime contract:** axiom or proved lemma for `li_rt_sqrt` (e.g. relative error bound on `result² - x` for `x ≥ 0`).
2. **Lean:** `Float.abs` (or `|·|`) lemmas in `Li.Discharge` linking MIR witness to the `ensures` Prop.
3. **Witness:** `lic verify` reports `mir_return_linked=` / `witnessed_ensures=` for the sqrt call chain (today partial on float paths).
4. **Corpus policy:** remove the “must stay open” branch in `contracts_discharge_corpus.sh` only after `check-autovc-open-goals.sh` passes **without** `--allow-open-vc`.

Placeholder in `docs/semantics/Discharge.lean`: `sqrt_open_bound_placeholder` (trivial) — not wired to generated `vc_sqrt_open_*` yet.

## Commands

```bash
./scripts/build.sh
./li-tests/tooling/contracts_discharge_corpus.sh
./li-tests/tooling/contracts_verify_lean.sh
build/compiler/lic/lic build li-tests/contracts_verify/sqrt_open_bound.li -o /dev/null   # expect fail
build/compiler/lic/lic build --allow-open-vc li-tests/contracts_verify/sqrt_open_bound.li -o /dev/null
```
