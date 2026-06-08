# Competitive safety matrix — Carbon / Mojo / Rust vs Li

**Issue:** [#65](https://github.com/li-langverse/lic/issues/65) · **Plan:** [2026-06-07-g-meta-competitive-safety-matrix](../superpowers/plans/2026-06-07-g-meta-competitive-safety-matrix.md)  
**north_star_fit:** ecosystem / HPC / web (AI-first tooling) · **G-meta** (positioning) · adjacent **Vision-LLM** agent JSON diagnostics  
**Pillar order:** proof → easy → fast — Li differentiates on **provable first**, not bolt-on safety.

**Honesty:** Li’s **target** is `lic build` = Lean proof certificate; **today** many **G-*** rows remain Partial or Missing — see [provability-gaps.md](../verification/provability-gaps.md). This matrix is **positioning**, not **G-meta** closure.

## Matrix (2026-H1)

| | **Proof-by-default** | **Memory / temporal safety** | **Python / LLVM interop** | **Agent / diagnostic surfaces** | **Maturity** |
|---|---------------------|------------------------------|---------------------------|-----------------------------------|--------------|
| **Carbon** | Safety goals in [p4880](https://docs.carbon-lang.dev/proposals/p4880.html); formal proof TBD | p4880 pivot to memory + temporal safety (design) | C++ interop heritage; LLVM backend planned | Not agent-first | 0.1 milestone slipped to **end 2026** |
| **Mojo 1.0b1** | Performance-first; optional safety annotations | Manual + language rules; no Lean certificate ([Mojo](https://mojolang.org/)) | **Python + LLVM** for AI/HPC kernels | Limited vs Li manifest vision | **Beta** (May 2025) |
| **Rust** | Borrow check at compile time; **no** proof certificate export | Ownership + lifetimes ([The Rust Reference](https://doc.rust-lang.org/reference/)) | Mature FFI / PyO3 ecosystem | `cargo` diagnostics; no proof artifact | **Stable** |
| **Li** | **`lic build` → Lean proof certificate** (strict-by-default policy; partial today) | Contracts + borrow + Lean VC discharge ([why-provable](../compiler/why-provable.md)) | C / LLVM today; Python interop on roadmap | **Vision-LLM partial:** `lic check --format=json`, `lic diagnose`, diagnostic-v1, manifest stub ([llm-first spec](../superpowers/specs/2026-05-16-li-llm-first-design.md)) | Production compiler; agent CI partial |

## Li differentiation (anchor)

1. **Provable pillar first** — safety and correctness are proof obligations checked toward Lean, not optional lints added after perf work.
2. **Certificate semantics** — ship target: binary only when proof obligations close (see [provability-gaps.md](../verification/provability-gaps.md) for current pipeline).
3. **Agent surfaces without proof shortcuts** — JSON diagnostics and manifests serve agents; they do **not** replace `requires` / `ensures` or **G-lean** discharge.

## Vision-LLM linkage (agent column only)

| Surface | Li today | Competitors (typical) | Gap / next step |
|---------|----------|----------------------|-----------------|
| Structured diagnostics | `lic check --format=json`, `lic diagnose` | `cargo` JSON (unstable), IDE LSP | Manifest CI gate ([#425](https://github.com/li-langverse/lic/issues/425) / [#464](https://github.com/li-langverse/lic/issues/464)) |
| Test manifest for agents | `li-tests/agent-manifest.json` export | Ad-hoc per repo | Expand suite index + stable ordering |
| Fix loop | `scripts/lic-fix-suggest.sh` stub | Copilot / rust-analyzer fixes | `lic edit --patch=json` spec only |
| Proof export | Lean artifacts on `lic build` (partial) | None in Carbon/Mojo/Rust mainstream | **G-meta** research — not closed by this doc |

**Master-plan row:** **Vision-LLM** stays `[ ]` partial until Done gates pass; this matrix **surfaces** agent gaps only.

## PH gate

**No new syntax or compiler changes** from this document. Implementation of interop or agent features requires separate **PH-*** issues and master-plan approval.

## Sources

- Carbon [p4880 — memory and temporal safety](https://docs.carbon-lang.dev/proposals/p4880.html)
- Mojo [1.0.0b1](https://mojolang.org/) release (May 2025)
- Rust [reference — ownership](https://doc.rust-lang.org/reference/ownership.html)
- Li [why-provable](../compiler/why-provable.md) · [provability-gaps](../verification/provability-gaps.md) · [strict-by-default](strict-by-default.md)
- Explorer digest: [2026-05-19-gaps](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-gaps.md) (issue body referenced missing `2026-05-19-explorer.md`)
