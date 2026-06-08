# Chapel 2.3+ → Li foreign bindings reference policy (normative rubric v1)

**Date:** 2026-06-07  
**Status:** Normative reference v1 — `plan-approved` on [lic#54](https://github.com/li-langverse/lic/issues/54); no `std/foreign` codegen in this slice  
**Depends on:** [Language design](2026-05-14-li-language-design.md), [LLM-first design](2026-05-16-li-llm-first-design.md), [Trusted net RFC](2026-05-16-li-trusted-net-rfc.md)  
**Companion:** [lic#113](https://github.com/li-langverse/lic/issues/113) (Chapel 2.8 HPC portability — G-par slice)  
**Plan:** [Chapel 2.3 Python interop reference policy](../plans/2026-06-07-li-chapel-23-python-interop-reference-policy.md)

## Purpose

Chapel 2.3.0 (December 2024) added a built-in **Python package module** for calling NumPy, PyTorch, and other Python libraries from Chapel without abandoning a systems-language core. Li's **AI-first** and **easy** pillars (after **provable**) need a **reference policy** — not a Chapel port — that states what to adopt and what must differ at the foreign boundary.

## Two-column rubric (≤1 screen)

| What Chapel got right | What Li must do differently |
|----------------------|------------------------------|
| Incremental `use Python` surface — opt-in, not language-wide dynamic typing | Same ergonomics via `import std.foreign.python` (future) — but every export is statically typed |
| NumPy/PyTorch call paths for HPC+AI workloads | Tier-3 **PH-ML** honesty: label `python+numpy` / `pytorch`; prove Li kernels first |
| `PyArray` bridge for ndarray-like data | Refinement types on shape/dtype; `modeling_gap` until Lean discharge |
| Sparse/GPU improvements in 2.3 release train | Cross-link [lic#113](https://github.com/li-langverse/lic/issues/113); prove host paths before device FFI |
| CLS + linter + Mason package ergonomics | Vision-LLM + `lic check --format=json` + `lip` — [LLM-first spec](2026-05-16-li-llm-first-design.md) |
| Embed-Python compile flags documented | Li: `extern proc` + capped `trusted.lean` only — [language design §trusted](2026-05-14-li-language-design.md) |
| Runtime-editable Python lambdas (`compileLambda`) | **Reject** — no runtime-eval foreign in user code; agents patch static `.li` |
| GIL handled inside Chapel runtime | Document as trusted runtime; Li defers GIL seam to human-approved `trusted.lean` issue |

## Checklist rows

| ID | Chapel 2.3 signal | Li acceptance criterion | Status | PH / G | Notes |
|----|-------------------|-------------------------|--------|--------|-------|
| **FB-01** | `use Python` package module | Document incremental foreign module pattern; implementation deferred to PH-FFI (proposed) | Stub (doc) | **G-ai** | No `use Python` port in v1 |
| **FB-02** | `Interpreter` / `Module` / `callMethod` | Boundary procs require full contracts; open VC blocks `lic build` | Stub (doc) | **G-trust**, Phase 2e | Mirrors `extern proc` rules |
| **FB-03** | NumPy `PyArray` / ndarray | Shape refinements + tier-3 `modeling_gap` until discharge | Partial (doc) | **G-math**, **G-ml**, PH-ML | `ph-ml.toml` cross-link |
| **FB-04** | PyTorch tensor bridge | Reuse Wave 13 device-buffer host contract pattern | Partial (doc) | **G-gpu**, **G-ml** | `li-ml` package |
| **FB-05** | `compileLambda` / runtime Python strings | **Forbidden** in Li user code | Stub (doc) | **G-ai** | Static manifests only |
| **FB-06** | Python C-API / `embed-python.sh` flags | Any C-API seam = audited `extern` in `trusted.lean` | Stub (doc) | **G-trust** | Human gate for axioms |
| **FB-07** | CSV/plot/data ingest via Python | Prefer **PH-IO-4/5/7** native `std.io` / `std.csv` / `std.plot` | Partial (doc) | PH-IO-4/5/7, lic#13 | Ingest without Python first |
| **FB-08** | Chapel 2.3 sparse/GPU release notes | Cross-link lic#113 portability rows; no duplicate matrix | Stub (doc) | **G-par**, **G-gpu** | Companion issue only |

## Proof gate at the foreign boundary

From [language design](2026-05-14-li-language-design.md):

1. User logic crossing a foreign boundary must emit dischargeable VCs or fail `lic build`.
2. `extern proc` bodies are trusted and listed in `trusted.lean` — not a loophole for user algorithms.
3. No `Any`, `unsafe`, or trust-by-prompt at the boundary.
4. Tier-3 ML benches may use Python drivers with explicit `modeling_gap`; Li native columns must not inherit unproved FFI semantics.

## PH-IO ingest-before-FFI guidance

| Data path | Preferred Li surface | Python FFI (if ever) |
|-----------|---------------------|----------------------|
| CSV / file ingest | `std.io` + `std.csv` (**PH-IO-4**, lic#13) | Last resort; `modeling_gap` |
| Summary JSON for agents | `std.summary` (**PH-IO-7**) | Not required for agent loops |
| Static plots / shareables | `std.plot` (**PH-IO-5**) | Not required for dashboard honesty |
| NumPy matmul baseline | Tier-3 `ph-ml.toml` competitor column only | Labeled `python+numpy`; not a Li proof |

## Agent tooling cross-link (FB-01 ergonomics)

| Chapel tooling | Li analogue (planned / partial) | Proof difference |
|----------------|--------------------------------|------------------|
| CLS (language server) | IDE / `lic check` diagnostics | Li: static gate, not full cert until 2f |
| `chplcheck` | `lic check` + decorator/contract exploits | Li: reserved-name + disjoint + VC rejects |
| Mason (package manager) | `lip` publish/install | Li: `lic build` static gate on dependencies |
| Python embed docs | — | Li: no embed-without-contract path |

Full Vision-LLM completion remains on master plan; this row is foreign-bindings ergonomics reference only.

## Tier-3 ML boundary matrix (FB-03 / FB-04)

Evidence: `benchmarks/competitive/ph-ml.toml`, [competitive landscape](../../benchmarks/competitive-landscape.md).

| Framework | Bench row | Li v1 policy | Proof axis |
|-----------|-----------|--------------|------------|
| NumPy BLAS | `matmul_lkir` | Competitor column only | **G-ml** stub |
| PyTorch CPU | `matmul_lkir`, `mlp_forward` | Competitor column; device-buffer watch | **G-ml**, **G-gpu** |
| Li native | same rows | Primary proof target | **G-math**, **G-ml** |

**Rule:** Chapel-style "call PyTorch from systems language" informs **ergonomics**; Li does not treat PyTorch return values as proved without discharge.

## Learned from

| Source | Li adaptation |
|--------|---------------|
| [Chapel 2.3 announcement](https://chapel-lang.org/blog/posts/announcing-chapel-2.3/) | Eight-row checklist (FB-01…FB-08) |
| [Chapel Python module](https://chapel-lang.org/docs/modules/packages/Python.html) | Boundary typing + GIL as trusted runtime concern |
| [Chapel 2.3.0 release](https://github.com/chapel-lang/chapel/releases/tag/2.3.0) | Evidence pin for competitive review |
| Li language design §trusted | Proof certificate on boundary; capped `trusted.lean` |

## Verification

- `./scripts/check-doc-provability-claims.sh` — no overclaim; see [provability-gaps.md](../../verification/provability-gaps.md) (**G-ai**)
- `./scripts/check-hpc-competitive.sh` — registry consistency after `last_reviewed` bump
