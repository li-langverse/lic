# Competitive safety matrix (Carbon / Mojo / Rust vs Li)

> **Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **north_star_fit:** ecosystem / HPC / web · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics  
> **Li anchor:** `lic build` targets a **Lean proof certificate** — provable pillar first, not bolt-on safety. See [why-provable](../compiler/why-provable.md) and honest limits in [provability-gaps](../verification/provability-gaps.md).

One-page positioning for AI/HPC language choices (2026-H1). **Not** a proof of compiler correctness (**G-meta** stays **Missing**).

## Matrix

| Row | Proof-by-default | Memory / temporal safety | Python / LLVM interop | Agent / diagnostic surfaces | Maturity (2026-H1) |
|-----|------------------|--------------------------|----------------------|----------------------------|--------------------|
| **Carbon** | p4880 pivot — safety goals; proof story TBD ([p4880](https://docs.carbon-lang.dev/proposals/p4880.html)) | Memory + temporal safety proposal; not shipped | C++ interop heritage | Not agent-first | 0.1 slipped to end 2026 |
| **Mojo 1.0b1** | Performance-first; optional static checks ([mojolang.org](https://mojolang.org/)) | Manual + language rules; no Lean certificate | Python + LLVM for AI/HPC | Limited vs Li manifest vision | Beta |
| **Rust** | Borrow check; no proof certificate ([The Rust Reference](https://doc.rust-lang.org/reference/)) | Ownership + lifetimes at compile time | FFI / PyO3 ecosystem | `cargo` diagnostics; no proof export | Stable |
| **Li** | **`lic build` → Lean proof certificate** (strict-by-default target; today partial — see [provability-gaps](../verification/provability-gaps.md)) | Contracts + borrow + Lean VC discharge | C/LLVM today; Python interop planned | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, `diagnostic-v1` | Production compiler; agent CI partial |

## Li differentiation (proof → easy → fast)

1. **Proof-by-default** — User logic is meant to ship only when VCs close in Lean; competitors above enforce safety or performance without exporting a kernel-checked proof artifact.
2. **Honest partial state** — Until Phase **2f** completes, `lic build` does not yet mean “binary iff proofs closed” everywhere; the matrix does not overclaim — see [provability-gaps](../verification/provability-gaps.md).
3. **No syntax from this doc** — Positioning only; new surface requires a separate PH-* gate.

## Agent surfaces (Vision-LLM row)

| Surface | Li today | Carbon / Mojo / Rust |
|---------|----------|----------------------|
| JSON diagnostics | `lic check --format=json`, `lic diagnose` ([diagnostic-v1](../schemas/diagnostic-v1.json)) | `cargo` JSON (unstable); others mostly human stderr |
| Agent manifest | Stub — [agent-handover-formats](agent-handover-formats.md), `li-tests/agent-manifest.json` | No first-class proof-aware manifest |
| Fix loops | `scripts/lic-fix-suggest.sh` stub | Ecosystem-specific |
| Proof export | Lean obligations + `prove_lean_ok` corpus (partial) | None of the rows export Lean certificates |

**Vision-LLM** master-plan row stays **Partial** — closure via [#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464). Spec: [llm-first design](../superpowers/specs/2026-05-16-li-llm-first-design.md).

## Sources

| Language | Primary citations |
|----------|-------------------|
| Carbon | [p4880 — memory and temporal safety](https://docs.carbon-lang.dev/proposals/p4880.html) |
| Mojo | [mojolang.org](https://mojolang.org/) — 1.0.0b1 LLVM + Python interop positioning |
| Rust | [The Rust Reference](https://doc.rust-lang.org/reference/) — ownership / lifetimes |
| Li | [why-provable](../compiler/why-provable.md), [strict-by-default](strict-by-default.md), [provability-gaps](../verification/provability-gaps.md) |

## Related plans

- [G-meta competitive safety matrix plan](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md) (issue #65)
- [plan-cross-links](plan-cross-links.md) — master plan ↔ **G-meta** / **Vision-LLM**
- Explorer digest: [2026-05-19-gaps](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md) (nearest to issue’s `2026-05-19-explorer.md` reference)
