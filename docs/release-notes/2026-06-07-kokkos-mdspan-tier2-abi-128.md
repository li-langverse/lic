# Release notes: 2026-06-07 — Kokkos mdspan tier-2 strided buffer ABI (#128)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Issue:** [#128](https://github.com/li-langverse/lic/issues/128)  
**PH / REQ:** PH-7e tier-2 field buffers · G-par strided disjoint  
**Author:** code_implementer agent

---

## Summary (one sentence)

Docs-only ABI rubric for Kokkos 4.6+ mdspan-backed Views: tier-2 strided buffer layouts (SoA/AoS), explicit copy/sync contract, pilot `heat_equation_2d` migration plan, and G-par strided-view gap note — no compiler codegen.

## Agent continuation (required)

1. Read: `docs/hpc/kokkos-mdspan-tier2-rubric.md`, language design §Phase 3 strided ABI, `provability-gaps.md` G-par row.
2. Then: #110 memory-space policy matrix; #15 decorator sync lowering; benchmarks catalog annotations (sub-phase E, separate PR).
3. Blocked on: human merge; codegen after #110 lands.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Rubric | `docs/hpc/kokkos-mdspan-tier2-rubric.md` | Competitive table, SoA/AoS patterns, copy/sync contract, pilot migration |
| Spec | `docs/superpowers/specs/2026-05-14-li-language-design.md` §Phase 3 | `ndview` layout enums, `hostbuffer`/`devicebuffer` sync rules, `FieldSoA`/`FieldAoS` |
| Gaps | `docs/verification/provability-gaps.md` G-par | Strided `ndview` disjoint obligation documented |
| Plan | `docs/superpowers/plans/2026-06-07-kokkos-mdspan-tier2-strided-abi-128.md` | Plan-approved sequencing |
| Cross-links | `docs/ecosystem/plan-cross-links.md` | Plan index entry |

## Not changed (scope fence)

- Compiler parser / MIR / codegen for `ndview`, `hostbuffer`, `devicebuffer`
- `trusted.lean`, benchmarks `catalog.toml`, tier-2 threshold ratios
- Shared C oracles (`md_core.c`, etc.)

## Breaking / Security / Performance

| Category | Status |
|----------|--------|
| Breaking | N/A — documentation only |
| Security | N/A — no trusted surface |
| Performance | N/A — no codegen change |
