# Benchmarks vendor policy handoff — Kokkos 4.6.x (benchmarks#27)

**Owner repo:** `li-langverse/benchmarks` (not lic)  
**Tracking issue:** [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27)  
**Lic context:** [lic#110](https://github.com/li-langverse/lic/issues/110)

## Requested benchmarks PR checklist

Human maintainer or `ci_maintainer` agent should open a PR on **benchmarks** with:

1. **Vendor pin** — Kokkos `4.6.02` (or latest 4.6.x patch) in vendor policy manifest.
2. **Registry row** — add `kokkos` to `hpc_libraries` with `li_status=watch` until Li `View` codegen ships.
3. **Compare set** — link tier-2 rows `heat_equation_2d`, `md_lennard_jones` for quarterly review.
4. **Honesty** — label Kokkos driver column `reference_native`; Li column remains `mixed` until Stage 3 migration.
5. **No threshold changes** — do not weaken `threshold_ratio_cpp` in the same PR.

## Suggested `registry.toml` sketch (benchmarks repo)

```toml
[[ecosystem]]
id = "kokkos"
track = "watch"
repo_url = "https://github.com/kokkos/kokkos"
vendor_pin = "4.6.02"
compare = ["heat_equation_2d", "md_lennard_jones"]
csv_lang = "kokkos"
kernel_honesty = "reference_native"
last_reviewed = "2026-06-08"
notes = "SYCL production 4.6.x; Li memory-space policy in lic#110."
```

## Li-side evidence (this PR)

- Rubric: `docs/hpc/kokkos-memory-execution-spaces-rubric.md`
- Migration: `docs/hpc/tier2-shared-c-migration-110.md`
- Std constants: `std/execution/memory_spaces.li`

No catalog or threshold edits in **lic** — handoff only.
