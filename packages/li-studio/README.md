# li-studio (compiler API in lic)

**Product** installers, deploy demos, plan loops, and studio CI moved to:

https://github.com/li-langverse/studio

**Compiler-facing** `import studio` library source remains here so `li-studio-ai`, `li-player`, and lic composable smokes keep building while the product repo matures. Do not add deploy/installer/product-only code under `packages/li-studio/` — use the studio repo.

For agent orchestration, `li-studio-ai` remains under `packages/li-studio-ai` until migrated to studio.ai.
