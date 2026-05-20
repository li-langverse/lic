# Contracts and proofs

Li is **provable-only** by design: if proof obligations are not discharged, there should be **no binary**.

!!! note "Implementation status"
    **Today:** contracts are required in the surface grammar and checked for well-formedness, but **Lean 4 discharge is not wired into `lic build` yet**. See **[Provability gaps](../verification/provability-gaps.md)** for the live gap register.

## On every procedure

```nim
def sqrt_pos(x: float) -> float
  requires x >= 0.0
  ensures result >= 0.0
  decreases 0
=
  ...
```

| Clause | Role |
|--------|------|
| `requires` | Precondition — caller must establish this |
| `ensures` | Postcondition — true on return (`result` names the return value) |
| `decreases` | Termination measure for the procedure body |

The **`=`** on the next line starts the **body**; it is not part of `decreases` and not assignment. See [Control flow and functions — The `=` after contracts](control-flow-and-functions.md#the--after-requires--ensures--decreases).

### Trivial `ensures true` on value returns

- **Default:** any **vacuous** `ensures` on a `def` that returns a value (not `-> unit`) emits **W0601** — the postcondition is a tautology or always-true formula (see below).
- **Strict:** `lic check` / `lic build` / `lic verify` with **`--strict-contracts`**, or **`LI_STRICT_CONTRACTS=1`**, turns that into **E0303** (build fails).
- **Exempt:** `extern proc` (opaque C), and **`-> unit`** (no meaningful `result`).

**Detected vacuous shapes (syntax-level, conservative):** literal **`true`**; **`not false`**; **`e == e`**, **`e <= e`**, **`e >= e`** for structurally identical `e`; **`A or B`** when `A` or `B` is vacuous (so `true or …` is caught); **`A and B`** when both sides are vacuous. This is not a full theorem prover — nested non-tautologies may still slip through.

**Regression / audit:** `li-tests/typecheck/vacuous_*.li` (strict must reject), `compile_ok_strict` entries in `li-tests/manifest.toml`, and **`scripts/audit-strict-good-contracts.sh`** (representative good programs under strict).

## On every loop

```nim
while n < limit
  invariant 0 <= n and n <= limit
  decreases limit - n
=
  n = n + 1
```

| Clause | Role |
|--------|------|
| `invariant` | True at the start of each iteration |
| `decreases` | Strictly decreases each iteration — proves the loop ends |

`parallel for` also carries `requires` (disjointness), `invariant`, and `decreases`.

## What gets proved

| Property | How |
|----------|-----|
| Type safety | Static checker |
| Index bounds | Refinements + checks |
| Memory / borrow | Borrow checker |
| Contract obligations | Lean 4 VC generation (**planned** — Phase 2e–2f) |
| Parallel races | Disjointness + `Send`/`Sync` (**partial** — policy heuristics today) |
| No `Any` / `sorry` | Hard reject |

## `lic check` vs `lic build`

| Command | Proof certificate? |
|---------|-------------------|
| `lic check` | **No** — IDE-speed feedback |
| `lic build` | **Target:** Lean must accept remaining goals · **Today:** static gate only ([gaps](../verification/provability-gaps.md)) |

When Phase **2f** lands, treat `lic build` like signing a theorem: the executable is the certificate artifact.

## Trusted base (tiny)

Only `docs/semantics/trusted.lean` may contain unproved axioms — minimal `IO` and audited `extern`. User application code never goes there.

## Why this is “mathematical”

Proofs are checked by the **Lean 4 kernel**, not by “we ran tests and it looked fine.” See [Why Li is provable](../compiler/why-provable.md).

## Common mistakes

| Mistake | What Li does |
|---------|----------------|
| Missing `decreases` | Compile error |
| `ensures` too weak | May still prove, but you lied — review specs |
| `ensures` too strong | Proof fails — strengthen code or weaken spec honestly |
| Using `sorry` | Rejected |

More: [Verification overview](../verification/overview.md) · [Provability gaps](../verification/provability-gaps.md).
