# Phase completion snapshot (2026-05-20)

Branch **`cursor/refinement-call-check-57b4`** (stacked on call-site `requires`). **Not merged to `main` yet** — merge via PR after CI.

## Status vs master plan

| Phase | Status on branch | On `main`? |
|-------|------------------|------------|
| **Foundation** | Parse, types, MIR, `lic build`, stdlib gate, packages, bench harness | **Yes** (through #72/#73) |
| **2e — Contracts + refinements** | Call-site `requires` (E0304), refinements (E0305), if-guard `>= 0`, import/extern, open-VC gate | **No** — PR [#78](https://github.com/li-langverse/lic/pull/78) + refinement commits |
| **2f — Lean in `lic build`** | `check-autovc-open-goals.sh` on build; `LI_BUILD_VERIFY_LEAN=1` runs `lean-verify-stub.sh`; CI strict | **Partial on main** — full gate on branch |
| **Phase H — li-httpd M1** | Infra + `li-http` / `li-net-httpd` stubs; Python routing oracle; **M1 `.li` routing** not started | **Infra only** on main |

## Merge checklist (human)

1. Push `cursor/refinement-call-check-57b4` (includes all 2e/2f commits).
2. Update or supersede draft PR **#78** with this branch.
3. CI green → review → merge (agents do not `gh pr merge`).
4. After merge: close **#77** (subset), run `install-agent-kit` if needed.

## 2e delivered on branch

- Callee `requires` at every call + **E0304** + plain-language errors
- **Refinement types** at calls and `var` init + **E0305**
- Const-local discharge; **`if x >= 0`** branch discharge for `x >= 0` facts
- Call-site + refinement VCs in `AutoVC.lean`

## 2f delivered on branch

- Build fails on open AutoVC (unless `LI_ALLOW_OPEN_VC=1`)
- With `LI_BUILD_VERIFY_LEAN=1`: `lake build` in `docs/semantics` via `lean-verify-stub.sh`
- CI: `LI_BUILD_VERIFY_LEAN_STRICT=1` + autovc check on greeter sample

## Phase H next (after merge)

Per [httpd-prerequisites.md](httpd-prerequisites.md): M1 `.li` — `match_route`, config desugar in Li, `li-tests/routing/` (Python oracle exists).
