# Competitive safety matrix (Carbon / Mojo / Rust vs Li)

**Status:** Positioning snapshot (2026-06-08)  
**Issue:** [#65](https://github.com/li-langverse/lic/issues/65)  
**north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics  
**Pillar order:** proof → easy → fast — see [why-provable](../compiler/why-provable.md) and [provability gaps](../verification/provability-gaps.md).

Li differentiation is **`lic build` = Lean proof certificate** (provable pillar first) — not optional safety bolted on later. This matrix is **honest positioning**; it does **not** close **G-meta** (compiler ↔ Lean equivalence remains research).

## Matrix

| | **Proof-by-default** | **Memory / temporal safety** | **Python / LLVM interop** | **Agent / diagnostic surfaces** | **Maturity (2026-H1)** |
|---|----------------------|-------------------------------|---------------------------|--------------------------------|----------------------------|
| **Carbon** | Safety goals in [p4880](https://docs.carbon-lang.dev/proposals/p4880.html); formal proof path TBD | p4880 pivot to memory + temporal safety (design proposal) | C++ heritage; interop with existing C++ stacks | Not agent-first | 0.1 milestone slipped to **end 2026** |
| **Mojo 1.0b1** | Performance-first; optional safety annotations | Manual + language rules; no proof certificate | [Python + LLVM](https://mojolang.org/) for AI/HPC kernels | Limited structured agent manifest vs Li vision | Beta (1.0.0b1, May 2025) |
| **Rust** | Borrow check at compile time; **no** proof certificate export | Ownership + lifetimes (compile-time) | Mature FFI / PyO3 ecosystem | `cargo` diagnostics; rustc JSON unstable | Stable production language |
| **Li** | **`lic build` → Lean proof certificate** (strict-by-default policy) — **partial today:** see [provability gaps](../verification/provability-gaps.md) | Contracts + borrow + Lean VC discharge (in progress) | C/LLVM codegen today; Python interop planned | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, `diagnostic-v1`, manifest stub | Production compiler; agent CI partial |

## Li anchor (proof-first)

```
lic build  →  binary exists  ⟺  proofs closed   (target; partial today)
lic check  →  fast IDE feedback only (not a certificate)
```

Until Phase **2f** lands, `lic build` runs parse, policy, typecheck, borrow, and codegen — **without** full Lean discharge. Do not overclaim: see [provability gaps](../verification/provability-gaps.md).

## Vision-LLM linkage (agent surfaces)

The **Agent / diagnostic surfaces** column maps to the master-plan **Vision-LLM** partial row — matrix **surfaces gaps**, does not close the tracker.

| Surface | Li today | Competitor pattern |
|---------|----------|-------------------|
| Structured errors | `lic check --format=json`, `lic diagnose` → [diagnostic-v1](../schemas/diagnostic-v1.json) | `cargo` text/JSON; Mojo/Carbon tooling TBD |
| Repo command manifest | [li-agent-manifest.toml](li-agent-manifest.toml) (v0 stub) | AGENTS.md / MCP per-project |
| Fix loop | [agent-handover-formats.md](agent-handover-formats.md) + `li-tests` smokes | Ad-hoc issue + branch + test |
| Proof status in diagnostics | **Not yet** — proof gaps separate from JSON diag | N/A (competitors lack proof cert) |

Closure path: [llm-first spec](../superpowers/specs/2026-05-16-li-llm-first-design.md) · issues [#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464). **No new syntax** without a separate PH-* gate.

## G-meta (positioning only)

**G-meta** (compiler ≡ Lean semantics) stays **Missing** — this doc is competitive positioning, not a proof of compiler correctness. See [plan](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md).

## Sources

- Carbon [p4880 — memory and temporal safety](https://docs.carbon-lang.dev/proposals/p4880.html)
- Mojo [1.0.0b1](https://mojolang.org/) release (May 2025)
- Rust [ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html) model
- Li [why-provable](../compiler/why-provable.md) · [llm-first spec](../superpowers/specs/2026-05-16-li-llm-first-design.md)
- Explorer digest: [2026-05-19-gaps](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md)

_Update when Carbon/Mojo timelines change; quarterly review with `ecosystem_explorer`._
