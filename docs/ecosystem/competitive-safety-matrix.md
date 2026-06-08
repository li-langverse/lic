# Competitive safety matrix — Carbon / Mojo / Rust vs Li

**Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Plan:** [2026-06-07-g-meta-competitive-safety-matrix.md](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md)  
**north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics  
**Pillar order:** proof → easy → fast — see [why-provable.md](../compiler/why-provable.md) and [provability-gaps.md](../verification/provability-gaps.md).

One-page positioning matrix (2026-H1). **Not** a proof closure — **G-meta** (compiler ≡ Lean) stays **Missing**. Competitors are not “unprovable”; Li differentiates on **proof-by-default** as the primary gate, not bolt-on safety.

## Matrix

| Language | Proof-by-default | Memory / temporal safety | Python / LLVM interop | Agent / diagnostic surfaces | Maturity (2026-H1) |
|----------|------------------|--------------------------|----------------------|----------------------------|--------------------|
| **Carbon** | Safety goals in [p4880](https://docs.carbon-lang.dev/proposals/p4880.html); formal proof certificate TBD | p4880 pivot: memory + temporal safety as 0.1 milestone focus | C++ interop heritage; LLVM backend | Not agent-first; no JSON diagnostic manifest | 0.1 slipped to **end 2026** per p4880 roadmap |
| **Mojo 1.0b1** | Performance-first; optional static checks, no Lean cert | Manual + language rules; no discharged proof obligations | **Python + LLVM** for AI/HPC ([mojolang.org](https://mojolang.org/)) | Limited vs Li agent manifest vision | Beta (1.0.0b1, May 2025) |
| **Rust** | Borrow check at compile time; **no** proof certificate export | Ownership + lifetimes; no temporal-logic discharge | FFI / PyO3 ecosystem; stable LLVM | `cargo` diagnostics (human text); no proof export | Stable production |
| **Li** | **`lic build` → Lean proof certificate** (strict-by-default target); see [why-provable](../compiler/why-provable.md) | Contracts + borrow + Lean VC discharge; [provability-gaps](../verification/provability-gaps.md) honest limits | C/LLVM today; Python interop planned (PH-gated) | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, `diagnostic-v1`, manifest stub — [llm-first spec](../superpowers/specs/2026-05-16-li-llm-first-design.md) | Production compiler; agent CI partial ([#425](https://github.com/li-langverse/lic/issues/425), [#464](https://github.com/li-langverse/lic/issues/464)) |

## Li differentiation anchor

Li’s north star is **`lic build` = Lean proof certificate** — provable pillar **first**, not optional memory safety bolted on after perf. Today `lic build` runs static gates without full Lean discharge on all paths; see [provability-gaps.md](../verification/provability-gaps.md) before overclaiming.

## Vision-LLM linkage (agent surfaces column)

The matrix **surfaces** agent gaps for the master-plan **Vision-LLM** partial row — it does **not** close that row.

| Surface | Li today | Carbon / Mojo / Rust |
|---------|----------|----------------------|
| Structured JSON diagnostics | `lic check --format=json`, `lic diagnose` (`diagnostic-v1`) | Cargo/Rustc text; Mojo/Carbon tooling not agent-manifest oriented |
| Agent test manifest | `scripts/export-li-tests-agent-slice.sh` → `li-tests/agent-manifest.json` (partial CI) | No equivalent proof-aware manifest |
| Fix-loop hints | `scripts/lic-fix-suggest.sh` (stub) | Ecosystem-specific, not unified |
| Proof status in diagnostics | VC / `prove_lean_ok` outcomes in test manifest; not yet in every `lic diagnose` code | No proof certificate in diagnostic stream |

**Closure path:** [2026-05-16-li-llm-first-design.md](../superpowers/specs/2026-05-16-li-llm-first-design.md) · issues [#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464).

## PH gate

This document is **positioning only**. No new syntax, compiler, or `trusted.lean` changes — defer to separate PH-* issues with human review.

## Sources

- Carbon p4880: https://docs.carbon-lang.dev/proposals/p4880.html
- Mojo 1.0b1: https://mojolang.org/
- Rust reference (ownership): https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html
- Li proof model: [why-provable.md](../compiler/why-provable.md)
- Explorer digest: [2026-05-19-gaps.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md)
