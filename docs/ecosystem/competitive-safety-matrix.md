# Competitive safety matrix — Carbon / Mojo / Rust vs Li

**Status:** Positioning doc (G-meta) — not a proof closure.  
**Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Plan:** [2026-06-07-g-meta-competitive-safety-matrix.md](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md)  
**north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics · proof → easy → fast

Li differentiation: **`lic build` targets a Lean proof certificate** (provable pillar first) — see [why-provable](../compiler/why-provable.md) and honest limits in [provability-gaps.md](../verification/provability-gaps.md). Competitors below optimize for adoption speed or memory safety without a discharged proof artifact.

## Matrix (2026-H1 snapshot)

| Row | Proof-by-default | Memory / temporal safety | Python / LLVM interop | Agent / diagnostic surfaces | Maturity (2026-H1) |
|-----|------------------|--------------------------|----------------------|----------------------------|--------------------|
| **Carbon** | Language goals include safety; **no Lean-style proof certificate** shipped ([p4880](https://docs.carbon-lang.dev/proposals/p4880.html)) | **p4880** pivots roadmap to memory + temporal safety (design phase) | C++ heritage; interop story evolving | Not agent-first | **0.1** milestone slipped to **end 2026** |
| **Mojo 1.0b1** | Performance-first; optional typing — **no proof export** ([Mojo 1.0.0b1](https://mojolang.org/)) | Manual + language rules; no formal discharge | **Python + LLVM** for AI/HPC kernels | Limited structured agent manifest vs Li vision | **Beta** (May 2025) |
| **Rust** | **Borrow check** at compile time; **no proof certificate** path | Ownership + lifetimes enforced statically | Mature **FFI / PyO3** ecosystem | `cargo` / `rustc` diagnostics; no proof export | **Stable** |
| **Li** | **`lic build` → Lean proof certificate** (strict-by-default policy; partial maturity — [provability-gaps.md](../verification/provability-gaps.md)) | Contracts + borrow + Lean VC discharge (gaps remain) | C/LLVM today; Python interop planned | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, `diagnostic-v1`, manifest stub | Production compiler; agent CI partial |

## Li anchor (proof pillar)

| Claim | Today | Target |
|-------|-------|--------|
| Proof gate | `lic build` runs static gates; Lean discharge **partial** ([G-lean](../verification/provability-gaps.md#g-lean), [G-vc](../verification/provability-gaps.md#g-vc)) | Binary ships only when proofs close |
| Compiler ≡ Lean | **G-meta Missing** — positioning only; see matrix, not closure | Long-horizon research |
| Agent ergonomics | JSON diagnostics shipped; manifest CI stub | **Vision-LLM** row — [#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464) |

## Vision-LLM linkage (agent surfaces column)

The matrix **surfaces** agent gaps; it does **not** close the master-plan **Vision-LLM** row.

| Surface | Li (partial) | Carbon / Mojo / Rust |
|---------|--------------|----------------------|
| Structured errors | `lic check --format=json`, `diagnostic-v1` schema | Compiler-native text/JSON; no proof-aware envelope |
| Fix loop entry | `lic diagnose`, `scripts/lic-fix-suggest.sh` (stub) | IDE/LSP or `cargo check` |
| Test manifest for agents | `scripts/export-li-tests-agent-slice.sh` → `agent-manifest.json` | Ad-hoc per ecosystem |
| Proof status in diagnostics | Planned — not in v0 JSON | N/A (no proof certificate) |

**Spec:** [2026-05-16-li-llm-first-design.md](../superpowers/specs/2026-05-16-li-llm-first-design.md) · **Handover:** [agent-handover-formats.md](agent-handover-formats.md)

## PH gate note

This doc is **positioning only**. No new syntax, compiler, or `trusted.lean` changes without a separate **PH-*** issue and provability review.

## Sources

- Carbon memory/temporal safety: [p4880](https://docs.carbon-lang.dev/proposals/p4880.html)
- Mojo 1.0 beta: [mojolang.org](https://mojolang.org/)
- Rust ownership: [The Rust Reference — Ownership](https://doc.rust-lang.org/reference/ownership.html)
- Li proof policy: [why-provable.md](../compiler/why-provable.md), [strict-by-default.md](strict-by-default.md)
- Explorer digest: [2026-05-19-gaps.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md)
