# Chapel 2.3+ Python/NumPy interop → Li AI-first foreign bindings reference policy (G-ai)

> **Issue:** [#54](https://github.com/li-langverse/lic/issues/54) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first (boundary contracts + Lean certificates), **Easy** syntax (incremental foreign surface), **Fast** only after proof (native Li kernels, not unproved FFI shortcuts)  
> **north_star_fit:** AI-first tooling, scientific computing · **Vision-LLM**, **PH-IO-4/5/7**, **PH-ML** · **G-ai**, **G-trust**, **G-ml**  
> **Learned from:** [Chapel 2.3 announcement](https://chapel-lang.org/blog/posts/announcing-chapel-2.3/), [Chapel Python module docs](https://chapel-lang.org/docs/modules/packages/Python.html), [Li language design spec](../specs/2026-05-14-li-language-design.md), [Li LLM-first design spec](../specs/2026-05-16-li-llm-first-design.md)

## Goal

Close the explorer **missing** rubric for **Chapel 2.3+ Python/NumPy interop** by producing a **reference policy** that:

1. Extracts what Chapel got right (incremental Python package surface, NumPy/PyTorch call paths, sparse/GPU ergonomics without abandoning a systems-language core).
2. States what Li must do differently: **proof certificates on boundary calls** — no `Any`, no `unsafe`, no unproved `extern` shortcuts in user code.
3. Links the policy to roadmap **AI-first** pillar, **Vision-LLM** agent ergonomics, **PH-IO** ingest rows (native `std.io` / `std.csv` instead of Python ingest), and tier-3 **PH-ML** competitive benches.

**No product codegen** in this slice — documentation, normative rubric, gap-registry updates only.

## Non-goals

- Implementing Python C-API interop, PyTorch bindings, or Chapel `use Python` in **lic**.
- Adding Chapel as a `bench_tier2` driver column or weakening `threshold_ratio_cpp`.
- Duplicating [lic#113](https://github.com/li-langverse/lic/issues/113) HPC portability checklist — cross-link only (companion slice).
- Editing `trusted.lean` (human-approved issues only).
- Adding GitHub Actions `schedule:` cron.

## Distinction from sibling explorer issues

| Issue | Abstraction | This plan (#54) |
|-------|-------------|------------------|
| **lic#113** Chapel 2.8 | HPC **portability** checklist (G-par, backends) | **Foreign bindings** reference policy (G-ai, Python/NumPy boundary) |
| **lic#13** PH-IO | Ship `std.io`, `std.csv`, `std.summary`, `std.plot` | Cross-link: native ingest **before** Python FFI for data paths |
| **lic#65** Carbon/Mojo | Competitive **safety matrix** | Chapel-specific Python interop ergonomics only |
| **benchmarks#27** | Release cadence tracker | Evidence pin for Chapel 2.3.0; no catalog threshold change |

## Chapel 2.3 → Li foreign-bindings policy (summary)

Full normative detail: [Foreign bindings reference policy spec](../specs/2026-06-07-li-foreign-bindings-reference-policy.md).

| Chapel 2.3 signal | Li policy row | Proof / PH axis | Owner |
|-------------------|---------------|-----------------|-------|
| `use Python` package module | Incremental `std/foreign/python` surface (future) | **G-ai** · **G-trust** | #54 → PH-FFI (proposed) |
| `Interpreter` + `Module` + `callMethod` | Typed boundary procs with full `requires`/`ensures` | **G-trust** · Phase 2e `extern` | #54 |
| NumPy `PyArray` / ndarray bridge | Shape-refinement + `modeling_gap` until proved | **G-math** · **G-ml** | PH-ML tier-3 |
| PyTorch tensor from Chapel arrays | Device-buffer host contract (Wave 13 pattern) | **G-gpu** · **G-ml** | `li-ml` package |
| `compileLambda` / runtime Python strings | **Reject** in Li user code — no runtime-eval foreign | **G-ai** (doc) | #54 |
| GIL handling in Chapel runtime | Document as trusted runtime concern; Li defers to explicit `raises IO` seam | **G-trust** | `trusted.lean` human gate |
| Sparse/GPU paths in Chapel 2.3 | Cross-link lic#113 portability; Li proves host paths first | **G-par** · **G-gpu** | lic#113 companion |

**Rule:** Li adopts Chapel's **ergonomic incremental surface** and **HPC+AI coexistence** model, but every foreign call crossing into Li user logic must either (a) discharge a Lean VC, or (b) be an audited `extern` listed in `trusted.lean` with explicit `modeling_gap` honesty.

## Li differentiation anchor (proof-friendly boundary)

| Dimension | Chapel 2.3+ (reference) | Li policy (must differ) |
|-----------|-------------------------|-------------------------|
| Boundary proof | C-API + runtime conversion; no Lean certificate | `lic build` emits boundary VCs; open VC → fail unless `--allow-open-vc` |
| Dynamic Python | `compileLambda`, CLI-editable `func` strings | **Forbidden** in user code; agents use `lic check --format=json` + static manifests |
| NumPy arrays | `PyArray` copy-in/copy-out | Refinement types on shape/dtype; tier-3 bench `modeling_gap` until proved |
| Trusted surface | Python.h + embed script flags | Capped `trusted.lean` + audited `extern proc` only |
| Ingest ergonomics | Call Python for CSV/plotting | **PH-IO-4/5/7** native `std.io` / `std.csv` / `std.plot` first |
| Agent tooling | CLS + `chplcheck` + Mason | Vision-LLM + `lic diagnose` + `lip` (see [LLM-first spec](../specs/2026-05-16-li-llm-first-design.md)) |

## Dependencies

| Track | Issue / doc | Role |
|-------|-------------|------|
| Extern contracts | Phase 2e, language design §trusted | Baseline `extern proc` rules |
| Native ingest | **PH-IO-4/5/7**, lic#13 | CSV/file/plot without Python |
| ML competitive | **PH-ML**, `ph-ml.toml` | NumPy/PyTorch tier-3 honesty rows |
| Agent ergonomics | **Vision-LLM**, LLM-first spec | `lic diagnose` vs Chapel CLS |
| HPC companion | **lic#113** | Sparse/GPU portability cross-link |
| Release tracker | **benchmarks#27** | Chapel 2.3.0 pin |
| Competitive intel | `registry.toml` `chapel` row | Quarterly review bump |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | Normative reference policy spec (FB-01…FB-08 rows) | Merged spec doc; `check-doc-provability-claims.sh` |
| **B** | Two-column rubric: Chapel wins vs Li must-differ | Linked from issue #54 + `competitive-landscape.md` |
| **C** | **G-ai** row draft in `provability-gaps.md` (Stub) | Summary + gap register tables updated |
| **D** | PH-IO cross-link: native ingest before Python FFI for data paths | lic#13 linkage; no std implementation |
| **E** | PH-ML tier-3 boundary honesty paragraph | `ph-ml.toml` / competitive landscape cross-link |
| **F** | Swarm gap `gap-ai-chapel-23-python-interop-reference` + registry bump | Registry YAML + `registry.toml` `last_reviewed` |

## Tests / benches

| Gate | Command / artifact | When |
|------|-------------------|------|
| Doc honesty | `./scripts/check-doc-provability-claims.sh` | Every PR |
| HPC competitive | `./scripts/check-hpc-competitive.sh` | After `registry.toml` bump |
| PH-ML honesty (unchanged) | `scripts/bench-ph-ml-competitive.sh` | No threshold change |
| Extern corpus (unchanged) | `li-tests/contracts_verify/` | Before any future FFI codegen |

**REQ mapping:**

| REQ | Acceptance |
|-----|------------|
| REQ-chapel-23-policy | Spec covers all eight Chapel 2.3 Python interop signals from issue #54 |
| REQ-gai-gap-row | **G-ai** appears in provability-gaps summary + register (Stub) |
| REQ-foreign-boundary | Policy cites Phase 2e `extern` + `trusted.lean` cap; no `unsafe` shortcut |
| REQ-ph-io-crosslink | PH-IO-4/5/7 linked as preferred ingest path over Python FFI |

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-ai** | Missing → **Stub** (doc) | AI-first foreign-bindings policy; no compiler slice |
| **G-trust** | Stub → Stub (honest) | Boundary `extern` rules referenced; no `trusted.lean` edit |
| **G-ml** | Stub → Stub (honest) | Tier-3 NumPy/PyTorch rows stay `modeling_gap` |
| **G-math** | Partial → Partial (honest) | Shape refinement at foreign boundary deferred |

## Rollout

1. Merge **this plan PR** (draft → ready) + human **`plan-approved`** on #54.
2. **Spec PR** (sub-phase A) — normative policy only; fix broken digest link (`2026-05-19-gaps.md` not `2026-05-19-explorer.md`).
3. **lic#113** implementers consume sparse/GPU cross-link; no duplicate portability matrix.
4. **lic#13** PH-IO implementers use § ingest-before-FFI guidance.
5. Implementation handoff → `code_implementer` only after `plan-approved` + explicit PH-FFI track scoped by human.

## Human-only

- [ ] Label **`plan-approved`** on #54 before any `std/foreign` codegen agents run.
- [ ] Decide whether to open **PH-FFI** master-plan row (proposed; not in this PR).
- [ ] Approve any `trusted.lean` axioms for Python C-API seam (separate human issue).
