# Benchmarks handoff: Kokkos 4.6.x vendor policy

**Lic issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**Benchmarks issue:** [#27](https://github.com/li-langverse/benchmarks/issues/27)  
**Owner repo:** `li-langverse/benchmarks` (lic does not own vendor pins)

## Purpose

File a checklist for benchmarks maintainers to pin Kokkos **4.6.x** in the competitive vendor policy when a Kokkos harness column is added. Lic tracks Kokkos as `watch` only until then.

## Checklist (for benchmarks PR)

- [ ] Pin Kokkos tag `4.6.02` (or latest 4.6.x patch) in `vendor/kokkos.version` or equivalent
- [ ] Document SYCL + OpenMP backend build flags in `docs/ecosystem/vendor-policy.md`
- [ ] Add `kokkos` row to tier-2 harness only when drivers exist for `heat_2d` and `md_lennard_jones`
- [ ] Set `kernel_honesty = reference_native` for Kokkos C++ drivers (not `shared_c_kernel`)
- [ ] Note OpenMP vs Threads hazard in row `notes` (Trilinos #1391)
- [ ] Link Li rubric: `lic/docs/hpc/kokkos-memory-execution-spaces-rubric.md`
- [ ] No `threshold_ratio_cpp` changes in the vendor-pin PR alone
- [ ] CI: skip Kokkos column when SYCL SDK absent (same pattern as Julia optional column)

## Lic registry mirror (this repo)

Update `benchmarks/competitive/registry.toml` `kokkos` row `notes` when benchmarks merges vendor pin — cite Kokkos 4.6.x and SYCL production status.

## Agent action

Open or comment on benchmarks [#27](https://github.com/li-langverse/benchmarks/issues/27) with this checklist. Do not self-merge benchmarks PRs.
