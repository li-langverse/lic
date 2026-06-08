# G-meta competitive safety matrix (Carbon / Mojo / Rust vs Li)

> **Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first (`lic build` = Lean proof certificate), **Easy** interop, **Fast** only after proof  
> **north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics  
> **Learned from:** [2026-05-19-gaps digest](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md), [why-provable.md](../compiler/why-provable.md), [2026-05-16-li-llm-first-design.md](../specs/2026-05-16-li-llm-first-design.md), [Carbon p4880](https://docs.carbon-lang.dev/proposals/p4880.html)

## Goal

Ship a **one-page competitive safety matrix** (`docs/ecosystem/competitive-safety-matrix.md`) that positions Li against **Carbon** (p4880 memory/temporal safety pivot), **Mojo 1.0b1** (LLVM + Python AI/HPC interop), and **Rust** (borrow-check safety without proof certificate) on:

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

## Dependencies

- Explorer finding: [lic#65](https://github.com/li-langverse/lic/issues/65) (this plan).
- **Vision-LLM** master-plan row (partial, L476) — matrix **surfaces gaps**, does not close the row.
- Sibling: [2026-06-07-vision-llm-done-gates.md](2026-06-07-vision-llm-done-gates.md) (if merged) — cite agent diagnostic smokes in matrix column.
- **benchmarks** digest hygiene: issue body references missing `2026-05-19-explorer.md`; nearest on `main` is [2026-05-19-gaps.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md) — add forward link in benchmarks follow-up PR (not blocking lic matrix).
- **Human-only:** maintainer review of competitive claims; no secrets in doc.

## Current state (evidence, 2026-06-07)

| Check | Result |
|-------|--------|
| `competitive-safety-matrix.md` on `main` | ❌ Absent — org code search 0 hits |
| Carbon p4880 / Mojo 1.0b1 cited in lic docs | ❌ Only in issue #65 + triage comment |
| **G-meta** row | **Missing** (research) — documented limit, not closable by positioning doc |
| **Vision-LLM** row | **Partial** — JSON diagnostics shipped; manifest CI stub |
| Duplicate PH-* / plan file | ❌ None — distinct from Vision-LLM Done gate plans |

## Sub-phases (exit gates)

| Sub | ID | Deliverable | Exit gate |
|-----|-----|-------------|-----------|
| **A** | REQ-GMETA-SCHEMA | **Matrix schema** — rows × columns frozen | Table header approved in PR review: languages × {proof-by-default, memory/temporal, interop, agent surfaces, maturity timeline} |
| **B** | REQ-GMETA-SOURCES | **Source citations** | Each cell cites primary source (Carbon p4880 URL, Mojo 1.0b1 release notes, Rust reference, Li `why-provable` + `lic build` flow) |
| **C** | REQ-GMETA-DOC | **One-page matrix** | `docs/ecosystem/competitive-safety-matrix.md` ≤ ~80 lines; Li column honest on partial Vision-LLM |
| **D** | REQ-GMETA-VLLM | **Vision-LLM linkage** | Matrix § "Agent surfaces" maps Li `lic diagnose` / `diagnostic-v1` / manifest stub vs competitors; links llm-first spec + Done gate plan — **no implementation** |
| **E** | REQ-GMETA-XLINK | **Cross-links** | Update `plan-cross-links.md`, master plan Doc checklist note, `provability-gaps.md` G-meta "documented limit" bullet cites matrix |
| **F** | REQ-GMETA-CI | **Doc CI** | `./scripts/check-doc-provability-claims.sh` exit 0 on matrix PR |

### Matrix schema (normative for implementer)

| Row | Proof-by-default | Memory / temporal safety | Python / LLVM interop | Agent / diagnostic surfaces | Maturity (2026-H1) |
|-----|------------------|--------------------------|----------------------|----------------------------|--------------------|
| **Carbon** | p4880 pivot — safety goals, proof TBD | p4880 memory + temporal safety proposal | C++ interop heritage | — (not agent-first) | 0.1 slipped to end 2026 |
| **Mojo 1.0b1** | Optional / performance-first | Manual + language rules; no Lean cert | Python + LLVM AI/HPC | Limited vs Li manifest vision | Beta |
| **Rust** | Borrow check, no proof certificate | Ownership + lifetimes at compile time | FFI / PyO3 ecosystem | `cargo` diagnostics; no proof export | Stable |
| **Li** | **`lic build` = Lean proof certificate** (strict-by-default) | Contracts + borrow + Lean discharge | C/LLVM today; Python interop planned | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, diagnostic-v1 | Production compiler; agent CI partial |

## Tests / benches

| ID | Path | Role |
|----|------|------|
| REQ-GMETA-CI | `scripts/check-doc-provability-claims.sh` | No overstated proof / Done claims |
| REQ-GMETA-LINK | `scripts/check-doc-links.sh` (if in CI) | External URLs resolve |

No perf benches — positioning doc only.

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-meta** | **Missing → Missing** | Matrix is **positioning**, not compiler ≡ Lean proof |
| **Vision-LLM** | **Partial → Partial** | Matrix lists agent-surface gaps; closure via [#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464) |
| **G-wrong-spec** | Unchanged | Matrix must not imply competitors are "unprovable" in social sense — focus on **Li differentiation** |

## Doc linkage (implementation PR)

After **`plan-approved`** on #65, a single docs PR must:

1. Add [competitive-safety-matrix.md](../../ecosystem/competitive-safety-matrix.md).
2. Update [plan-cross-links.md](../../ecosystem/plan-cross-links.md) — G-meta / positioning row.
3. Add master plan Doc checklist bullet under L476 area (cross-link matrix; Vision-LLM row stays `[ ]` until Done gates pass).
4. Add `provability-gaps.md` G-meta row footnote → matrix URL.
5. Optional **benchmarks** PR: forward link from `2026-05-19-gaps.md` or stub `2026-05-19-explorer.md` redirect (fixes broken issue reference).

## Rollout

1. **This PR (plan only):** add this file + `plan-cross-links.md` entry; post issue comment; request `plan-approved`.
2. **Implementation PR (after `plan-approved`):** sub-phases A–F; `docs_maintainer` or `ecosystem_explorer` agent.
3. **Close #65** when matrix merged on `main` + cross-links land — reason `already_implemented` with matrix URL evidence.

## Human-only

- [ ] Add label **`plan-approved`** on #65 before implementation agents run.
- [ ] Remove **`plan-needed`** after plan PR review.
- [ ] Review competitive claims for accuracy (Carbon/Mojo timelines change frequently).
- [ ] Do not self-merge if governance cross-links touch **roadmap** (lic-only PR is OK).
