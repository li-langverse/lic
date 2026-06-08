# Competitive safety matrix (Carbon / Mojo / Rust vs Li)

**Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Plan:** [2026-06-07-g-meta-competitive-safety-matrix.md](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md)  
**north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics · proof → easy → fast

One-page positioning for how Li differs from Carbon (p4880 memory/temporal safety pivot), Mojo 1.0b1 (LLVM + Python AI/HPC), and Rust (borrow-check without proof certificate). **Positioning only** — does not close [G-meta](../verification/provability-gaps.md#g-meta) (compiler ↔ Lean equivalence remains research).

## Matrix

| Language | Proof-by-default | Memory / temporal safety | Python / LLVM interop | Agent / diagnostic surfaces | Maturity (2026-H1) |
|----------|----------------|--------------------------|----------------------|----------------------------|--------------------|
| **Carbon** | Safety goals in [p4880](https://docs.carbon-lang.dev/proposals/p4880.html); formal proof certificate **TBD** | p4880 pivots roadmap to **memory + temporal safety** (design proposal) | C++ heritage; interop with existing C++ stacks | Not agent-first (no manifest / JSON diag story) | **0.1** milestone slipped to **end of 2026** ([p4880](https://docs.carbon-lang.dev/proposals/p4880.html)) |
| **Mojo 1.0b1** | Performance-first; optional safety annotations | Manual + language rules; no Lean / proof export | **Python + LLVM** for AI/HPC kernels ([mojolang.org](https://mojolang.org/)) | Limited structured agent loop vs Li [Vision-LLM](../superpowers/specs/2026-05-16-li-llm-first-design.md) | **Beta** (1.0.0b1, May 2025) |
| **Rust** | Borrow checker + types; **no** proof certificate shipped with `cargo build` | Ownership + lifetimes at compile time ([Rust reference](https://doc.rust-lang.org/reference/)) | **FFI** + **PyO3** ecosystem for Python extension | `cargo` / `rustc` diagnostics; no proof artifact export | **Stable** (1.x) |
| **Li** | **Target:** [`lic build` = Lean proof certificate](../compiler/why-provable.md) (strict-by-default). **Today:** static gate without universal Lean discharge — see [provability gaps](../verification/provability-gaps.md) | Contracts + borrow + Lean VCs (partial slices shipped) | C / LLVM today; Python interop on roadmap | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, [diagnostic-v1](../schemas/diagnostic-v1.json), [agent manifest](li-agent-manifest.toml) stub | Production compiler; agent CI partial ([#425](https://github.com/li-langverse/lic/issues/425), [#464](https://github.com/li-langverse/lic/issues/464)) |

## Li differentiation (anchor)

Li orders pillars **proof → easy → fast**. Safety is not a late bolt-on milestone: the **intent** is that `lic build` ships only when proof obligations discharge in Lean ([why-provable](../compiler/why-provable.md)). Competitors may enforce memory safety at compile time without exporting a kernel-checked proof certificate — that is the honest contrast this matrix captures.

Until **Phase 2f** lands, docs must not overclaim: prefer “`lic build` runs the current static gate; see [provability gaps](../verification/provability-gaps.md)” over “fully proved in Lean today.”

## Vision-LLM linkage (agent surfaces column)

The master-plan **Vision-LLM** row stays **[ ] partial** — this matrix **surfaces** gaps, it does not close them.

| Surface | Li (shipped / partial) | Carbon / Mojo / Rust (typical) |
|---------|------------------------|----------------------------------|
| Structured diagnostics | `lic check --format=json`, `lic diagnose` → [diagnostic-v1](../schemas/diagnostic-v1.json) | Compiler text / LSP; no Li-style JSON envelope |
| Agent command manifest | [li-agent-manifest.toml](li-agent-manifest.toml) + `li-tests/agent-manifest.json` export | Ad-hoc README / AGENTS.md patterns |
| Fix-loop contract | [agent-handover-formats.md](agent-handover-formats.md) | Ecosystem-specific |
| Proof status in diag | **Gap** — diagnostics do not yet export Lean VC / gap IDs per error | N/A (no proof certificate model) |

**Done gates** for Vision-LLM remain in [2026-05-16-li-llm-first-design.md](../superpowers/specs/2026-05-16-li-llm-first-design.md) and sibling issues — **no new syntax** without a PH gate.

## G-meta (positioning vs proof)

| Gap | Status after this doc | Notes |
|-----|----------------------|-------|
| **G-meta** | **Missing** (unchanged) | Matrix is **positioning**, not C++ compiler ≡ Lean semantics |
| **Vision-LLM** | **Partial** (unchanged) | Agent column lists surfaces; closure via dedicated Vision-LLM PRs |

## Sources

- Carbon p4880: https://docs.carbon-lang.dev/proposals/p4880.html
- Mojo: https://mojolang.org/
- Rust reference: https://doc.rust-lang.org/reference/
- Li: [why-provable](../compiler/why-provable.md), [provability-gaps](../verification/provability-gaps.md), [llm-first spec](../superpowers/specs/2026-05-16-li-llm-first-design.md)
- Explorer digest: [2026-05-19-gaps](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md) (benchmarks repo)
