# Competitive safety matrix (Carbon / Mojo / Rust vs Li)

**Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Plan:** [2026-06-07-g-meta-competitive-safety-matrix.md](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md)  
**north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics  
**Pillar order:** proof → easy → fast — see [why-provable.md](../compiler/why-provable.md) and [provability-gaps.md](../verification/provability-gaps.md).

This page is **positioning research**, not a proof closure. **G-meta** (compiler ↔ Lean equivalence) stays **Missing**. Li differentiation is **`lic build` = Lean proof certificate** — provable pillar first, not safety bolted on later.

## Matrix (2026-H1)

| | **Proof-by-default** | **Memory / temporal safety** | **Python / LLVM interop** | **Agent / diagnostic surfaces** | **Maturity (2026-H1)** |
|---|----------------------|-------------------------------|---------------------------|--------------------------------|------------------------|
| **Carbon** | Safety goals in [p4880](https://docs.carbon-lang.dev/proposals/p4880.html); formal proof TBD | p4880 pivot: memory + temporal safety as primary roadmap focus | C++ interop heritage; LLVM backend planned | Not agent-first; no JSON diagnostic manifest | 0.1 milestone slipped to **end 2026** |
| **Mojo 1.0b1** | Performance-first; optional safety annotations | Manual + language rules; no Lean certificate | **Python + LLVM** for AI/HPC ([mojolang.org](https://mojolang.org/)) | Limited vs Li manifest vision; REPL-oriented | **Beta** (May 2025) |
| **Rust** | Borrow check at compile time; **no proof certificate export** | Ownership + lifetimes enforced statically | Mature FFI / PyO3 ecosystem | `cargo` diagnostics; rustc JSON unstable for agents | **Stable** |
| **Li** | **`lic build` → Lean proof certificate** (strict-by-default); see [provability-gaps.md](../verification/provability-gaps.md) | Contracts + borrow + Lean VC discharge (partial today) | C/LLVM today; Python interop planned | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, `diagnostic-v1`, manifest stub — [llm-first spec](../superpowers/specs/2026-05-16-li-llm-first-design.md) | Production compiler; agent CI partial ([#425](https://github.com/li-langverse/lic/issues/425), [#464](https://github.com/li-langverse/lic/issues/464)) |

## Li anchor (honest)

| Claim | Today | Target |
|-------|-------|--------|
| `lic build` = proof certificate | **Partial** — parse, typecheck, borrow, codegen; Lean Tier B when installed | Binary ships **iff** Lean kernel closes all VCs |
| `lic check` | Fast IDE feedback — **not** a certificate | Unchanged |
| Competitor parity on proof | **No** — Carbon/Mojo/Rust do not ship Lean certificates | Li differentiation is provable pillar first |

Do not overclaim: see [provability-gaps.md](../verification/provability-gaps.md) until Phase **2f** lands.

## Vision-LLM linkage (agent surfaces column)

The matrix **surfaces gaps** for the master-plan **Vision-LLM** row — it does **not** close it.

| Surface | Li today | Competitors (typical) | Closure owner |
|---------|----------|----------------------|---------------|
| Structured JSON diagnostics | `lic check --format=json`, `lic diagnose` | `cargo` / compiler stderr; no proof export | [#425](https://github.com/li-langverse/lic/issues/425) |
| Diagnostic schema | `diagnostic-v1` | — | Done gate plan |
| Agent manifest | `li-tests/agent-manifest.json` stub | — | [#464](https://github.com/li-langverse/lic/issues/464) |
| Fix-loop handover | [agent-handover-formats.md](agent-handover-formats.md) | Ad hoc | Vision-LLM spec |

**PH gate:** positioning doc only — no new syntax or compiler changes without a separate PH-* issue.

## Sources

- Carbon [p4880 — memory and temporal safety](https://docs.carbon-lang.dev/proposals/p4880.html)
- Mojo [1.0.0b1 release](https://mojolang.org/) (May 2025)
- Rust [ownership and borrowing](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)
- Li [why-provable.md](../compiler/why-provable.md) · [strict-by-default.md](strict-by-default.md)
- Explorer digest: [2026-05-19-gaps.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md)
