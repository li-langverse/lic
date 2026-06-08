# Competitive safety matrix — Carbon / Mojo / Rust vs Li

**Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Plan:** [2026-06-07-g-meta-competitive-safety-matrix.md](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md)  
**Audience:** ecosystem positioning, agent planners — **not** a proof closure for **G-meta**  
**north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics

Li differentiates on **provable pillar first**: `lic build` targets a Lean proof certificate ([why-provable](../compiler/why-provable.md)), not optional safety bolted on after launch. **Today** the certificate is still partial — see [provability-gaps](../verification/provability-gaps.md).

## Matrix (2026-H1)

| Language | Proof-by-default | Memory / temporal safety | Python / LLVM interop | Agent / diagnostic surfaces | Maturity |
|----------|------------------|--------------------------|----------------------|----------------------------|----------|
| **Carbon** | Safety goals in [p4880](https://docs.carbon-lang.dev/proposals/p4880.html); formal proof TBD | p4880 pivot: memory + temporal safety as 0.1 milestone | C++ heritage; interop story evolving | Not agent-first | 0.1 slipped to **end 2026** |
| **Mojo 1.0b1** | Performance-first; optional safety annotations | Manual discipline + language rules; no proof export | **Python + LLVM** for AI/HPC ([mojolang.org](https://mojolang.org/)) | Compiler errors; no proof/manifest export | Beta (May 2025) |
| **Rust** | Borrow check at compile time; **no** proof certificate | Ownership + lifetimes; no temporal logic layer | Mature FFI / PyO3 ecosystem | `cargo` / `rustc` diagnostics; no structured agent manifest | Stable |
| **Li** | **`lic build` = Lean proof certificate** (strict-by-default target) | Contracts + borrow + Lean VC discharge (partial) | C/LLVM today; Python interop on roadmap | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, `diagnostic-v1`, manifest stub | Production compiler; agent CI partial |

**Sources:** Carbon [p4880](https://docs.carbon-lang.dev/proposals/p4880.html) · Mojo [1.0.0b1](https://mojolang.org/) · Rust reference (borrow checker) · Li [why-provable](../compiler/why-provable.md) · [strict-by-default](strict-by-default.md)

## Li anchor (proof → easy → fast)

1. **Proof** — `lic build` must close proofs before shipping (target); `lic check` is IDE speed only.
2. **Easy** — Python-math surface and agent JSON diagnostics reduce agent token cost without skipping contracts.
3. **Fast** — LLVM codegen and tier-1 benches only after honest proof status is documented.

**G-meta** (compiler ≡ Lean semantics) remains **Missing** / research — this matrix is **positioning**, not meta-proof closure. See [provability-gaps § G-meta](../verification/provability-gaps.md#g-meta).

## Vision-LLM linkage (agent surfaces column)

The matrix **surfaces** agent gaps; it does **not** close the master-plan **Vision-LLM** row.

| Surface | Li today | Carbon / Mojo / Rust |
|---------|----------|----------------------|
| Structured JSON diagnostics | `lic check --format=json`, `lic diagnose` ([diagnostic-v1](../schemas/diagnostic-v1.json)) | Compiler text / JSON varies; no proof export |
| Agent test manifest | `li-tests/agent-manifest.json` stub ([llm-first spec](../superpowers/specs/2026-05-16-li-llm-first-design.md)) | None comparable |
| Fix-loop hints | `scripts/lic-fix-suggest.sh` stub | Ecosystem-specific |
| Proof-aware agent handover | [agent-handover-formats](agent-handover-formats.md) | N/A |

**Closure** for Vision-LLM Done gates: sibling issues [#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464) — no new syntax without PH gate.

## PH gate note

This document is **positioning only**. Compiler, syntax, or **G-meta** implementation requires a separate PH-* issue and human review. Do not weaken [strict-by-default](strict-by-default.md) or overclaim [provability-gaps](../verification/provability-gaps.md) status from this matrix.
