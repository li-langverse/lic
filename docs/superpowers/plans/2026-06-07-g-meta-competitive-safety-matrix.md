# G-meta competitive safety matrix (Carbon / Mojo / Rust vs Li)

> **Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first (`lic build` = Lean proof certificate), **Easy** interop, **Fast** only after proof  
> **north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics  
> **Learned from:** [2026-05-19-gaps digest](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md), [why-provable.md](../compiler/why-provable.md), [2026-05-16-li-llm-first-design.md](../specs/2026-05-16-li-llm-first-design.md), [Carbon p4880](https://docs.carbon-lang.dev/proposals/p4880.html)

## Goal

Ship a **one-page competitive safety matrix** ([competitive-safety-matrix.md](../../ecosystem/competitive-safety-matrix.md)) that positions Li against **Carbon** (p4880 memory/temporal safety pivot), **Mojo 1.0b1** (LLVM + Python AI/HPC interop), and **Rust** (borrow-check safety without proof certificate) on:

- **Proof-by-default** — `lic build` Lean certificate vs optional/bolt-on safety
- **Memory / temporal safety model** — what is enforced at compile time vs runtime vs research
- **Python / LLVM interop** — AI/HPC adoption surfaces
- **Agent / diagnostic surfaces** — JSON diagnostics, manifest, fix loops (Vision-LLM row)

Link matrix outcomes to the master-plan **Vision-LLM** partial row and the **G-meta** honest limit in [provability-gaps.md](../../verification/provability-gaps.md). **No new syntax or compiler changes** without a separate PH-* gate.

## Non-goals

- Closing **G-meta** (compiler ↔ Lean equivalence remains **Missing** / research).
- Claiming Carbon/Mojo/Rust parity on proof — Li differentiation is **provable pillar first**.
- Weakening `threshold_ratio_cpp` or benchmark catalog to appear competitive on perf.
- New org repos or governance edits (human checklist required).
- Implementing Vision-LLM gates — sibling plans [#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464) own agent manifest CI.
- Editing `trusted.lean`.

## Sub-phases (exit gates)

| Sub | ID | Deliverable | Exit gate |
|-----|-----|-------------|-----------|
| **A** | REQ-GMETA-SCHEMA | **Matrix schema** | Table header: languages × {proof-by-default, memory/temporal, interop, agent surfaces, maturity timeline} |
| **B** | REQ-GMETA-SOURCES | **Source citations** | Each row cites primary source (Carbon p4880, Mojo 1.0b1, Rust reference, Li `why-provable`) |
| **C** | REQ-GMETA-DOC | **One-page matrix** | [competitive-safety-matrix.md](../../ecosystem/competitive-safety-matrix.md) ≤ ~80 lines |
| **D** | REQ-GMETA-VLLM | **Vision-LLM linkage** | Matrix § “Agent surfaces” maps Li diagnostics vs competitors — **no implementation** |
| **E** | REQ-GMETA-XLINK | **Cross-links** | `plan-cross-links.md`, master plan Doc note, `provability-gaps.md` G-meta footnote |
| **F** | REQ-GMETA-CI | **Doc CI** | `./scripts/check-doc-provability-claims.sh` exit 0 |

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-meta** | **Missing → Missing** | Matrix is **positioning**, not compiler ≡ Lean proof |
| **Vision-LLM** | **Partial → Partial** | Matrix lists agent-surface gaps; closure via [#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464) |

## Rollout

1. **Plan PR:** this file + `plan-cross-links.md` entry.
2. **Implementation PR:** [competitive-safety-matrix.md](../../ecosystem/competitive-safety-matrix.md) + cross-links (sub-phases A–F).
3. **Close #65** when matrix merged on `main` — reason `already_implemented` with matrix URL evidence.
