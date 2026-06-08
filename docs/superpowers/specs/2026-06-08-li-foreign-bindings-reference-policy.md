# Li foreign bindings reference policy (Chapel 2.3+ Python interop)

**Date:** 2026-06-08  
**Status:** Accepted reference policy (research / plan — **no implementation** in this issue)  
**Issue:** [lic#54](https://github.com/li-langverse/lic/issues/54)  
**north_star_fit:** AI-first tooling, scientific computing · **G-ai** · easy pillar (after provability)  
**Plan map:** [plan-cross-links](../../ecosystem/plan-cross-links.md) · [master plan](../plans/2026-05-14-li-master-plan.md) · [provability-gaps](../../verification/provability-gaps.md)

## What this page is for

Capture what **Chapel 2.3+** got right in Python/NumPy interop ergonomics, and what **Li must do differently** so foreign calls stay **proof-friendly** (no `unsafe`, no `Any`, no runtime-trust shortcuts). This is the reference policy for a future `std/foreign` / `std/python` surface — not an implementation plan.

**Out of scope (lic#54):** embedding CPython, NumPy converters, or PyTorch bindings in the compiler.

## Pillar order (non-negotiable)

| Priority | Pillar | Foreign-binding rule |
|----------|--------|----------------------|
| 1 | **Provability** | Boundary calls are **trusted seams** with explicit `requires`/`ensures`; user logic crossing the seam must discharge VCs or fail `lic build`. |
| 2 | **Easy syntax** | Incremental Python surface (import module → call function) like Chapel; sugar desugars to audited `extern proc` + typed marshaling. |
| 3 | **Fast execution** | Only after (1)+(2): zero-copy paths where proofs permit; no perf claim without bench ingest. |

Canonical vision: [vision-and-roadmap](../../ecosystem/vision-and-roadmap.md) → [roadmap AI-first milestones](https://github.com/li-langverse/roadmap/blob/main/docs/roadmap/milestones.md).

## Chapel 2.3+ — what they got right

Source: [Chapel 2.3 announcement](https://chapel-lang.org/blog/posts/announcing-chapel-2.3/) · [Python package module](https://chapel-lang.org/docs/modules/packages/Python.html) · [2.3.0 release](https://github.com/chapel-lang/chapel/releases/tag/2.3.0).

| Pattern | Chapel behavior | Why it matters for Li |
|---------|-----------------|----------------------|
| **Incremental surface** | `use Python; var interp = new Interpreter(); var np = interp.importModule("numpy");` — no full FFI codegen per library | Agents and HPC users adopt one module, then opt into NumPy/PyTorch as needed |
| **Native → Python marshaling** | Nested Chapel arrays copy into PyTorch tensors via `TypeConverter` registration | Keeps systems-language core; defers ecosystem to Python where proofs are hard |
| **Runtime Python lambdas** | `compileLambda` + CLI `func=` for element-wise ops without recompile | AI-first ergonomics for experiment loops (trade: dynamic trust) |
| **Array-like bridge** | `PyArray` wraps `array.array` and `numpy.ndarray` with Chapel indexing | Sparse/GPU paths can share one array abstraction |
| **Distributed hook** | Docs note Python modules with distributed Chapel (locale-aware) | HPC + Python without abandoning PGAS mental model |

Chapel explicitly marks the Python module API as **under active development** and links against CPython (not PyPy). Li should assume the same C-API constraint for v1.

## What Li must do differently

Chapel optimizes for **productivity and ecosystem reach**. Li optimizes for **`lic build` = proof certificate** at the user/boundary contract.

| Chapel choice | Li policy |
|---------------|-----------|
| Implicit copy + dynamic Python objects | **Typed boundary contracts** — every cross-language value has a Li type + marshaling spec; opaque Python handles are `raises Foreign` + capability-scoped |
| `compileLambda` / runtime `func=` without static proof | **Harness-only** — allowed in bench drivers (`benchmarks/competitive/`) and agent tools; **forbidden** in shipped `lic build` user modules unless wrapped in explicit trusted block |
| Trusted CPython C API inside package module | **Single audited seam** — mirror [trusted-net RFC](2026-05-16-li-trusted-net-rfc.md): declarations only in `std/runtime/seam.li` (+ manifest), implementation in audited C shim |
| No proof certificate on `np.matmul` semantics | **Boundary `ensures`** — e.g. shape preservation, dtype width, finiteness guards; float paths cite **G-hw** axioms where IEEE proofs stop |
| Performance via PIC Python embedding | **Proof before perf** — zero-copy only when Lean/MIR witnesses alias safety; else honest copy + bench row |

**Forbidden:** `unsafe`, `Any`, `sorry`, user-defined `extern proc` outside `std/runtime/seam.li`, silent widening/narrowing at the boundary.

## Li reference policy (phased)

### Phase 0 — today (shipped patterns)

| Surface | Location | Role |
|---------|----------|------|
| **C `extern proc` FFI** | [effects-and-io](../../language/effects-and-io.md) · [phase-04-runtime](../plans/2026-05-14-phase-04-runtime-stdlib.md) | Lowest layer; all foreign calls eventually lower here |
| **Trusted runtime seam** | `std/runtime/seam.li` · [trusted-net RFC](2026-05-16-li-trusted-net-rfc.md) | Canonical `extern proc` declarations + `raises` effects |
| **PH-IO ingest (no Python)** | `std/io`, `std/csv`, `std/summary`, `std/plot` · [stdlib.md](../../language/stdlib.md) | Replace Python/Node ingest in proof-db and benchmarks with compile harnesses |
| **PH-ML competitor drivers** | `benchmarks/competitive/ph-ml.toml` · [competitive-landscape](../../benchmarks/competitive-landscape.md) | Honest PyTorch/NumPy/JAX ratios — **harness**, not user `import python` |
| **Asset ingest** | `packages/li-assets` glTF ingest | Typed ingest boundary (studio/sim), not arbitrary foreign code |

### Phase 1 — spec / stub (`std/foreign` research)

- Add `G-ai` row to [provability-gaps](../../verification/provability-gaps.md): foreign AI/Python boundary proofs (**Stub**).
- Define `raises Foreign` effect (parallel to `raises Net`, `raises IO`).
- Document marshaling kinds: `Copy`, `BorrowView` (proof-required), `OpaqueHandle` (trusted).
- Register converters in `security/trusted-extern-manifest.toml` — no ad-hoc `extern` in packages.

### Phase 2 — incremental Python module (future PH)

Mirror Chapel ergonomics **without** Chapel trust model:

```text
import std.foreign.python as py   # future — not implemented

def train_step(weights: array[N, f32]) raises Foreign -> array[N, f32]
  requires weights.len == N
  ensures result.len == N
  decreases 0
=
  # Desugars to audited seam calls + boundary VC discharge
  py.call("torch", "matmul", ...)
```

**Sparse/GPU path:** `std/sparse` + `@gpu` (see **G-gpu**, **G-math**) own device buffers; Python only as **fallback harness** until native kernels prove.

### Phase 3 — AI-first agent ergonomics

Align with [LLM-first design](2026-05-16-li-llm-first-design.md) and [world-studio AI workflows](../../game-dev/world-studio-vision.md#8-ai-first-workflows):

- Agents call `lic check --format=json` after foreign-boundary edits.
- Bench evidence for any zero-copy claim: `li-tests/` + `benchmarks/results/` ingest.
- MCP / Cursor SDK patches never bypass `lic build` on user modules.

## Learned from (Chapel 2.3+ vs Li)

| Source | **Adopt** | **Reject** |
|--------|-----------|------------|
| Chapel `Python` package | Incremental `importModule` / `Function` surface; `PyArray` array-like bridge | Runtime lambda injection in proved user code |
| Chapel `--library-python` | Clear init/teardown lifecycle for embedded interpreters | PIC-only perf path without proof story |
| Li `std/runtime/seam` | Single audited `extern` manifest | Per-package `extern proc` sprawl |
| Li PH-IO ingest | Li-native CSV/summary/plot stubs replacing Python scripts | Permanent Python sidecar for std ingest |
| Li PH-ML tier-3 | Named competitor columns with honest `executed` flags | Claiming parity from unproved foreign calls |

## Tracking

| ID | Area | Status | Evidence path |
|----|------|--------|---------------|
| **G-ai** | Foreign AI/Python boundary | **Stub** — policy only (this doc) | Future: `li-tests/foreign/`, `std/foreign/` |
| **G-net** | Trusted syscall surface | **Partial** | [trusted-net RFC](2026-05-16-li-trusted-net-rfc.md) |
| **G-ml** | ML convergence / training | **Stub** | [ml-convergence-program](../../verification/ml-convergence-program.md) |
| **PH-IO-4..7** | Ingest without Python | **Partial** | `std/io`, `std/csv`, `std/summary`, `std/plot` |
| **Vision-LLM** | Agent JSON diagnostics | Research | [LLM-first design](2026-05-16-li-llm-first-design.md) |

## Related

- [Master plan — Learn from other ecosystems](../plans/2026-05-14-li-master-plan.md#learn-from-other-ecosystems-implementing-li-features)
- [Competitive HPC landscape](../../benchmarks/competitive-landscape.md) (Chapel watch row)
- [Strict by default](../../ecosystem/strict-by-default.md)
- [PH-ML GPU execution tracker](../../game-dev/PH-ML-GPU-execution-tracker.md)
- Explorer digest: [2026-05-19](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-19-explorer.md)
