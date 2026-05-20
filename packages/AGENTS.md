# Packages workspace — agent notes

**Coordination:** [active-agent-claims.md](../docs/ecosystem/active-agent-claims.md) in `lic` — check before editing any `li-*` package.

**Scaffold:** `./scripts/li-new-package <name> --official --workspace packages` from repo root.

**Org mirror:** `./scripts/push-official-package-repo.sh <name> --create` (requires `GH_TOKEN`).

**Do not** hand-edit `li.toml` schema or skip `PKG-*` / `CHANGELOG.md` for official packages.

## SOTA + Li-only solvers

New numerics, simulation, physics, math, or engineering algorithms must follow **`.cursor/rules/li-sota-benchmark-li-only.mdc`**: implement in **Li** (`packages/*`), register **`lic/benchmarks/`** with C oracle, document SOTA in **`docs/benchmarks/sota-reference-registry.md`**.
