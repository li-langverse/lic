# Release notes: 2026-06-07 — Kokkos memory + execution spaces (#110)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**PH / REQ:** PH-7e tier-2 memory model · G-par / G-gpu cross-space sync  
**Author:** code_implementer agent

---

## Summary (one sentence)

Docs-only policy matrix for Kokkos 4.6 memory spaces, execution spaces, and View lifecycle: explicit copy/sync contract, `shared_c_kernel` migration rubric, `heat_equation_2d` pilot plan, and benchmarks vendor handoff — no compiler codegen.

## Agent continuation (required)

1. Read: `docs/hpc/kokkos-memory-execution-spaces-rubric.md`, language design §Phase 3 memory spaces, `provability-gaps.md` G-par / G-gpu rows.
2. Then: #15 decorator sync lowering; #116 OpenMPTarget offload; benchmarks Kokkos 4.6.x vendor pin ([#27](https://github.com/li-langverse/benchmarks/issues/27)).
3. Blocked on: human merge; codegen after #128 mdspan ABI coordination.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Rubric | `docs/hpc/kokkos-memory-execution-spaces-rubric.md` | Policy matrix, execution-space OpenMP default, copy/sync contract, migration appendix |
| Spec | `docs/superpowers/specs/2026-05-14-li-language-design.md` §Phase 3 | `MemorySpace`, `ExecutionSpace`, `View[T, Space, Layout]` |
| Gaps | `docs/verification/provability-gaps.md` G-par, G-gpu | Cross-space sync obligations documented |
| Plan | `docs/superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md` | Plan-approved sequencing |
| Cross-links | `docs/ecosystem/plan-cross-links.md` | Plan index entry |

## Not changed (scope fence)

- Compiler parser / MIR / codegen for `MemorySpace`, `ExecutionSpace`, `@sync_*`
- `trusted.lean`, benchmarks `catalog.toml`, tier-2 threshold ratios
- Shared C oracles (`md_core.c`, heat stencil C, etc.)

## Breaking / Security / Performance

| Category | Status |
|----------|--------|
| Breaking | N/A — documentation only |
| Security | N/A — no trusted surface |
| Performance | N/A — no codegen change |
