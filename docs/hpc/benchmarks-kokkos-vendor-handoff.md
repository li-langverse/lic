# Benchmarks repo — Kokkos 4.6.x vendor policy handoff (#110, sub-phase F)

**Status:** Checklist for **benchmarks** repo PR (lic does not own vendor catalog)  
**Issue:** [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27) · **Lic issue:** [#110](https://github.com/li-langverse/lic/issues/110)

Lic defines the memory/execution-space **policy**; benchmarks owns competitive **vendor pins** and catalog rows.

---

## PR checklist (file on benchmarks repo)

Copy into benchmarks PR body when implementing #27:

```markdown
## Kokkos 4.6.x vendor policy (#27, lic #110 handoff)

- [ ] Pin `KOKKOS_VERSION=4.6.02` (or latest 4.6.x patch) in competitive registry / CI env
- [ ] Document in `docs/ecosystem/hpc-libraries.md`: Kokkos status moves from `missing` → `watch` with pinned version
- [ ] Add `HPC_COMPETITIVE_KOKKOS_VERSION=4.6.02` to snapshot script output (mirrors lic `scripts/hpc-competitive-snapshot.sh`)
- [ ] No change to `threshold_ratio_cpp` until lic tier-2 row reaches stage 3 (explicit sync, no shared C)
- [ ] Link lic rubric: https://github.com/li-langverse/lic/blob/main/docs/hpc/kokkos-memory-execution-spaces-rubric.md
- [ ] Explorer digest cross-link: `docs/ecosystem/explorer-digests/2026-05-20-explorer.md`
```

---

## Lic-side env hook (already present)

`scripts/hpc-competitive-snapshot.sh` emits `HPC_COMPETITIVE_KOKKOS_VERSION` when set:

```bash
export HPC_COMPETITIVE_KOKKOS_VERSION=4.6.02
./scripts/hpc-competitive-snapshot.sh
```

---

## Human review required

- Benchmarks PR must **not** be self-merged by agents.
- Threshold and catalog honesty require maintainer sign-off.
- Kokkos driver benches (when added) remain **`watch`** track until lic pure-Li stage 3.

---

## Related

- [Kokkos rubric](kokkos-memory-execution-spaces-rubric.md)
- [Tier-2 migration](tier2-shared-c-migration.md)
- [Kokkos 4.6.02 release](https://github.com/kokkos/kokkos/releases/tag/4.6.02)
