# Benchmarks handoff — Kokkos 4.6.x vendor policy

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110) sub-phase F  
**Benchmarks issue:** [#27](https://github.com/li-langverse/benchmarks/issues/27)  
**Owner:** `li-langverse/benchmarks` (lic does **not** edit vendor pins)

## Purpose

Track [Kokkos 4.6.02](https://github.com/kokkos/kokkos/releases/tag/4.6.02) in competitive / reference builds so tier-2 comparison rows stay honest while Li lands the memory-space model in [#110](https://github.com/li-langverse/lic/issues/110).

## PR checklist (file on benchmarks repo)

Copy into benchmarks PR body when implementing #27:

```markdown
## Agent deliverable
- [ ] Pin Kokkos **4.6.x** (minimum 4.6.02) in vendor policy / Docker bench image
- [ ] Document SYCL backend as optional dimension (do not require for CI green)
- [ ] Add `hpc_libraries.kokkos.version` field to ecosystem explorer snapshot
- [ ] Note DualView deprecation — reference drivers use explicit `deep_copy` only
- [ ] Link migration rubric: li-langverse/lic `docs/hpc/kokkos-memory-execution-spaces-rubric.md`
- [ ] No change to `threshold_ratio_cpp` or tier-2 Li row labels in same PR
- [ ] CI: Kokkos build smoke (Serial + OpenMP) on Linux x86_64

## Vendor policy snippet (suggested)

| Library | Pin | Notes |
|---------|-----|-------|
| Kokkos | 4.6.02 | SYCL/HIP/CUDA backends optional; OpenMP default for tier-2 compare |

## Explorer digest

Update `docs/ecosystem/explorer-digests/` row: `hpc_libraries[kokkos].li_status=spec` (was `missing`) after lic #110 merges.
```

## lic-side actions (done in #110 PR)

- [x] Rubric + migration docs merged
- [x] Language design Phase 3 enums specified
- [ ] Close lic #110 when above + benchmarks #27 checklist filed (human opens benchmarks PR)

## Threshold policy

**No threshold changes** in this track. Kokkos vendor pin is for **reference / watch-list** rows only until Li pure-Li tier-2 kernels land.
