# Chapel 2.8 → Li HPC portability checklist (normative rubric v1)

**Date:** 2026-06-07  
**Status:** Normative rubric v1 — `plan-approved` on [lic#113](https://github.com/li-langverse/lic/issues/113); implementation slices tracked via lic#109, lic#110, lic#54  
**Depends on:** [Execution surface](2026-05-25-li-execution-surface.md), [Parallel design](2026-06-06-li-parallel-design.md), [Execution decorators](2026-05-16-li-execution-decorators.md)  
**Companion:** [lic#54](https://github.com/li-langverse/lic/issues/54) (Chapel Python/NumPy interop — G-ai tooling)  
**Plan:** [Chapel 2.8 portability rubric](../plans/2026-06-07-li-chapel-28-hpc-portability-rubric.md)

## Purpose

Chapel 2.8 (March 2026) advances **hardware and launcher portability** without changing Li’s proof-first model. This checklist converts Chapel release signals into **Li acceptance rows** for `std/execution` decorators and tier-2 physics — **reference only**, no Chapel runtime dependency.

## Checklist rows

| ID | Chapel 2.8 signal | Li acceptance criterion | Status | PH / G | Notes |
|----|-------------------|-------------------------|--------|--------|-------|
| **CP-01** | RISC-V CPUs + Qthreads 1.23 | Document host `@parallel` + task-pool portability on RISC-V as **watch**; no qthreads port | Partial (doc) | PH-7b, **G-par** | Li uses OpenMP/libomp + li_rt pool; prove disjoint first |
| **CP-02** | ROCm 6.3 / 7 AMD GPU | Decorator `@gpu` maps to ROCm/HIP execution space in rubric; implementation owned by **lic#110** | Partial (doc) | PH-7e, **G-gpu** | Cross-link Kokkos View memory spaces |
| **CP-03** | LLVM 21 backend | PH-7e **loop-invariant vectorization metadata** goals documented for `@vectorized` inner loops | Partial (doc) | PH-7e, **G-par** | Inform LLVM IR metadata; no perf claim |
| **CP-04** | `--system-launcher-flags` (Slurm) | `lipar run` launcher passthrough checklist (explicit flags vs env hacks) | Partial (doc) | PH-7, **G-par-dist** | No Chapel launcher code |
| **CP-05** | CLS + `chplcheck` + Mason | One-page ergonomics comparison → Vision-LLM / `lic diagnose` reference | Stub (doc) | **G-ai** | Owned by **lic#54** companion; cross-link only |
| **CP-06** | HPE Cray EX troubleshooting docs | Competitive landscape quarterly review + benchmarks#27 pin `2.8.0` | Partial (doc) | PH-5b | `registry.toml` `last_reviewed` bump |

## Decorator ↔ backend axis matrix

Do not conflate **policy** (lic#109 RAJA) with **platform** (this rubric) or **memory layout** (lic#110 Kokkos).

| Li decorator / surface | Host CPU (OpenMP) | SIMD (LLVM) | Device (ROCm/HIP) | Distributed launch |
|------------------------|-------------------|-------------|-------------------|--------------------|
| `@parallel(disjoint=…)` | **v1 target** | N/A (separate axis) | N/A | `lipar run` rank partition |
| `@vectorized(lanes=N)` | Same thread | **PH-7e metadata** (CP-03) | N/A | N/A |
| `@gpu` | Reject / stub | N/A | **watch** (CP-02) | N/A |
| `@cpu` | Default host | Composable with `@vectorized` | Reject | Allowed on rank 0 |

**Proof gate:** Each row requires **G-par** disjoint proofs before backend-specific codegen is advertised as supported.

## Tier-2 kernel minimum portability set

| Kernel id | Required rows | Optional rows |
|-----------|---------------|---------------|
| `md_lennard_jones` | CP-01 | CP-04 |
| `three_body` | CP-01 | — |
| `heat_equation_2d` | CP-01, CP-03 | CP-04 |
| `rigid_body_stack` | CP-01 | CP-02 (watch) |
| `cloth_swing` | CP-01 | CP-02 (watch) |

## PH-7e LLVM metadata goals (CP-03 detail)

From Chapel 2.8 loop-invariant code motion for vectorization — **Li planning targets only:**

1. `@vectorized(lanes=N)` on inner `for` emits LLVM vector-width hint when disjoint + bounds proved.
2. Outer `@parallel` must not suppress inner vectorization (prescriptive vs descriptive separation — see lic OpenMP rubric).
3. Document metadata expectations in master plan §7e; implementation tracked separately from this rubric.

## Agent tooling cross-link (CP-05 → lic#54)

| Chapel tooling | Li analogue (planned / partial) | Proof difference |
|----------------|--------------------------------|------------------|
| CLS (language server) | IDE / `lic check` diagnostics | Li: static gate, not full cert |
| `chplcheck` | `lic check` + decorator exploits | Li: reserved-name + disjoint rejects |
| Mason (package manager) | `lip` publish/install | Li: static gate on `lic build`; see [provability-gaps.md](../../verification/provability-gaps.md) |

Full G-ai foreign-bindings policy remains on **lic#54**; this row is ergonomics reference only.

## Learned from

| Source | Li adaptation |
|--------|---------------|
| [Chapel 2.8 announcement](https://chapel-lang.org/blog/posts/announcing-chapel-2.8/) | Six-signal checklist (CP-01…CP-06) |
| [Chapel RISC-V docs](https://chapel-lang.org/docs/2.8/platforms/riscv.html) | Watch row; OpenMP-first Li strategy |
| [Chapel Slurm launcher flags](https://chapel-lang.org/docs/2.8/usingchapel/launcher.html#common-slurm-settings) | `lipar run` passthrough checklist |
| Li parallel design spec | Axes separation (SIMD ≠ parallel ≠ distributed) |

## Verification

- `./scripts/check-doc-provability-claims.sh` — no overclaim on proof certificate
- `./scripts/check-hpc-competitive.sh` — registry consistency after `last_reviewed` bump
