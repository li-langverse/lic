# Competitive safety matrix — Carbon / Mojo / Rust vs Li

**Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Plan:** [2026-06-07-g-meta-competitive-safety-matrix](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md)  
**north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics  
**Honest limits:** [provability-gaps.md](../verification/provability-gaps.md) — **G-meta** stays **Missing**; this matrix is positioning, not compiler ≡ Lean closure.

## Li differentiation (anchor)

Li orders pillars **proof → easy → fast**. The target gate is **`lic build` = Lean proof certificate** — safety and contracts are not optional bolt-ons added after performance. See [why-provable.md](../compiler/why-provable.md).

**Today:** `lic build` runs parse, policy, typecheck, borrow, and codegen **without** full Lean discharge yet. Claims below describe **target** vs **today** honestly.

## Matrix (2026-H1)

| Language | Proof-by-default | Memory / temporal safety | Python / LLVM interop | Agent / diagnostic surfaces | Maturity (2026-H1) |
|----------|------------------|--------------------------|----------------------|------------------------------|--------------------|
| **Carbon** | Safety goals in [p4880](https://docs.carbon-lang.dev/proposals/p4880.html); proof story TBD | p4880 pivots roadmap to **memory + temporal safety** (not perf-first) | C++ heritage; Python interop not primary | Not agent-first | **0.1 slipped to end 2026** per p4880 |
| **Mojo 1.0b1** | Performance-first; optional static checks | Manual + language rules; **no Lean certificate** | **Python + LLVM** for AI/HPC ([mojolang.org](https://mojolang.org/)) | Limited vs Li manifest / JSON diag vision | **Beta** (May 2025 1.0.0b1) |
| **Rust** | Borrow/lifetime check; **no exported proof certificate** | Ownership + lifetimes at compile time (stable model) | FFI / **PyO3** ecosystem | `cargo` diagnostics; no proof export | **Stable** |
| **Li** | **`lic build` → Lean proof certificate** (strict-by-default target) | Contracts + borrow + Lean VC discharge (partial today) | C/LLVM today; Python interop planned | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, diagnostic-v1, manifest stub — see [llm-first spec](../superpowers/specs/2026-05-16-li-llm-first-design.md) | Production compiler; agent CI partial |

## Vision-LLM linkage (agent surfaces column)

The matrix **surfaces** agent gaps; it does **not** close the master-plan **Vision-LLM** row.

| Surface | Li today | Carbon / Mojo / Rust |
|---------|----------|----------------------|
| Structured diagnostics | `lic check --format=json`, `lic diagnose` ([diagnostic-v1](../schemas/diagnostic-v1.json)) | `cargo` JSON (Rust); Carbon/Mojo lack Li-style proof-oriented JSON |
| Agent manifest | `li-tests/agent-manifest.json` export stub | No equivalent proof-gated manifest |
| Fix loop | `scripts/lic-fix-suggest.sh` stub | Ecosystem-specific |
| Done gates | [#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464) | N/A |

**PH gate:** No new syntax or compiler changes from this doc — implementation stays in Vision-LLM / PH-* issues.

## Sources

- Carbon [p4880 — memory and temporal safety](https://docs.carbon-lang.dev/proposals/p4880.html)
- Mojo [1.0.0b1](https://mojolang.org/) — LLVM + Python AI/HPC positioning
- Rust [Reference — ownership](https://doc.rust-lang.org/reference/ownership-and-deconstruction.html)
- Li [why-provable](../compiler/why-provable.md), [provability-gaps](../verification/provability-gaps.md), [llm-first design](../superpowers/specs/2026-05-16-li-llm-first-design.md)
- Explorer context: [2026-05-19-gaps digest](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md) (issue #65 referenced a missing `2026-05-19-explorer.md` path)

## Related

- [plan-cross-links](plan-cross-links.md) — G-meta / Vision-LLM map
- [Master plan Vision-LLM row](../superpowers/plans/2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting)
