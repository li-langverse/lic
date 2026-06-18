# Competitive safety matrix — Carbon / Mojo / Rust vs Li

**Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Plan:** [2026-06-07-g-meta-competitive-safety-matrix.md](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md)  
**north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics  
**Pillar order:** proof → easy → fast — see [why-provable](../compiler/why-provable.md) and honest limits in [provability-gaps](../verification/provability-gaps.md).

One-page positioning for languages Li is compared against in AI/HPC adoption conversations. **Not** a perf bench — see [competitive-landscape](../benchmarks/competitive-landscape.md) for tier-2 harness rows.

## Matrix (2026-H1 snapshot)

| | **Proof-by-default** | **Memory / temporal safety** | **Python / LLVM interop** | **Agent / diagnostic surfaces** | **Maturity (2026-H1)** |
|---|----------------------|-------------------------------|---------------------------|--------------------------------|------------------------|
| **Carbon** | Safety goals in [p4880](https://docs.carbon-lang.dev/proposals/p4880.html); formal proof certificate **not** shipped | p4880 pivots roadmap to **memory + temporal safety** (design); enforcement model evolving | C++ interop heritage; LLVM backend | Not agent-first; no JSON diagnostic manifest | **0.1 milestone slipped** to end 2026 per p4880 |
| **Mojo 1.0b1** | Performance-first; optional typing — **no** Lean proof certificate | Language rules + manual discipline; no discharged contract corpus | **Python + LLVM** for AI/HPC ([mojolang.org](https://mojolang.org/)) | Compiler errors; no proof-export or agent manifest vision | **Beta** (1.0.0b1, May 2025) |
| **Rust** | **Borrow check** at compile time — safety without proof objects | Ownership + lifetimes; no temporal-safety proof layer | Mature **FFI / PyO3** ecosystem | `cargo` diagnostics; rustc JSON unstable / secondary | **Stable** production language |
| **Li** | **`lic build` targets Lean proof certificate** ([strict-by-default](strict-by-default.md)); **partial** today — see [provability-gaps](../verification/provability-gaps.md) | Contracts + borrow + Lean discharge path; **G-meta** (compiler ≡ Lean) still **Missing** | C / LLVM today; Python interop on roadmap (not v1 claim) | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, `diagnostic-v1`; manifest stub — [llm-first spec](../superpowers/specs/2026-05-16-li-llm-first-design.md) | Production compiler; agent CI partial |

## Li differentiation (honest)

1. **Provable pillar first** — Li positions safety as **theorems checked before ship**, not a later bolt-on milestone (contrast Carbon p4880 timeline slip).
2. **Certificate, not checklist** — Rust proves memory rules via the borrow checker; Li aims for **discharged Lean obligations** on `lic build` (aspirational until **G-lean** / **G-meta** close — [provability-gaps](../verification/provability-gaps.md)).
3. **Agent surfaces without proof shortcuts** — Vision-LLM JSON diagnostics improve fix loops; they **do not** replace `requires` / `ensures` or kernel discharge.

## Vision-LLM linkage (gaps surfaced, not closed)

| Li surface | Status | Competitor gap |
|------------|--------|----------------|
| `lic check --format=json` + `diagnostic-v1` | **Shipped** | Carbon/Mojo lack comparable agent schema |
| `lic diagnose` | **Shipped** | Rust `cargo` human-first; no proof export |
| `li-tests/agent-manifest.json` slice | **Partial** — CI stub | No peer publishes test-manifest for agents |
| `lic edit --patch=json` | **Spec only** | — |

Master-plan **Vision-LLM** row stays `[ ]` until Done gates ([#425](https://github.com/li-langverse/lic/issues/425), [#464](https://github.com/li-langverse/lic/issues/464)). This matrix **documents** the column; it does not close the row.

## G-meta note

**G-meta** (C++ compiler ≡ Lean semantics) remains **Missing** / research. This page is **positioning only** — see [provability-gaps § G-meta](../verification/provability-gaps.md#g-meta). No new syntax or compiler changes without a separate PH-* gate.

## Sources

- Carbon [p4880 — memory and temporal safety](https://docs.carbon-lang.dev/proposals/p4880.html)
- Mojo [1.0.0b1](https://mojolang.org/) release positioning (LLVM + Python)
- Rust [ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html) model
- Li [why-provable](../compiler/why-provable.md), [strict-by-default](strict-by-default.md), [llm-first design](../superpowers/specs/2026-05-16-li-llm-first-design.md)
- Explorer digest: [2026-05-19-gaps](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md) (issue #65 referenced missing `2026-05-19-explorer.md`)

**Review:** competitive timelines change — refresh quarterly or when Carbon/Mojo ship major milestones.
