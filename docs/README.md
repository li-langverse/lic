# Li documentation

This folder is the **developer-facing** entry point for the Li language and compiler. Internal agent plans also live under `superpowers/`; user-oriented docs live here.

## New here?

1. Read [Getting started](getting-started.md) for toolchain and repo layout  
2. Skim [Architecture overview](architecture/overview.md) for the compile pipeline  
3. Use the [language design spec](superpowers/specs/2026-05-14-li-language-design.md) when you need exact rules for types, numerics, or data structures  

## Guides

| Page | Audience | Content |
|------|----------|---------|
| [Getting started](getting-started.md) | Contributors | Build prerequisites, directory map, phases |
| [Architecture](architecture/overview.md) | Compiler hackers | Lex → MIR → LLVM, module boundaries |
| [Formal verification](verification/overview.md) | Everyone | **Pillar 1** — Lean gate, provable-only |
| [Documentation style](contributing/documentation.md) | Doc authors | Voice, structure, examples |

## Specifications

| Spec | Scope |
|------|--------|
| [li-tests](../li-tests/README.md) | All tests — manifest, suites, CI |
| [Language design spec](superpowers/specs/2026-05-14-li-language-design.md) | Three pillars, types, contracts, roadmaps |
| [Master implementation plan](superpowers/plans/2026-05-14-li-master-plan.md) | Phase 0–6 delivery order |
| [Benchmarks plan](superpowers/plans/2026-05-14-benchmarks-and-simulations.md) | MD, N-body, ML perf harness |

## Phase plans (implementation detail)

Located in `superpowers/plans/`:

- `2026-05-14-phase-00-bootstrap.md` through `phase-05-tetris.md`  
- `2026-05-14-benchmarks-and-simulations.md`  

## Conventions

- **Li** = the language; **lic** = the compiler CLI  
- Surface syntax examples use `nim` code fences (indentation-based)  
- When docs and code disagree, file a bug — the design spec is intended to be the contract until RFCs change it  
