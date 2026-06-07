# Wave A integration (WA-P6) — honest closeout

**Branch:** `cursor/wave-a-stdlib-unblock`  
**Date:** 2026-05-26

## Merged (in integration order)

| Branch | Commit | Notes |
|--------|--------|-------|
| `cursor/wa-p1-pfloat` | `7258e282` | `sqrt_open_bound` → `Li.Discharge.sqrt_open_bound_spec` |
| `cursor/wa-p5-gpar-lean` | `60b44d11` | `_par*` policy witnesses + `discharge_par_parallel_lean.sh` |
| `cursor/wa-p4-workspace-8a` | `4e4ff070` | `li-sim-scientific` proof-complete smoke |
| `cursor/wa-p2-tier1-perf` | — | **Skipped** (no commits ahead of base) |
| `cursor/wa-p3-tier0-tests` | — | **Skipped** (no commits ahead of base) |

P5 merge conflict in `vc_emit_lean.cpp` resolved to keep **both** sqrt discharge and par policy witness paths.

## Gate snapshot (post-merge, compiler rebuilt)

| Gate | Exit | Result |
|------|------|--------|
| `lic build sqrt_open_bound` + `check-autovc-open-goals.sh` | 0 | P-float specimen closed |
| `LI_TIER1_PERF_STRICT=1 check-tier1-li-vs-cpp.sh` | 1 | `matmul_blocked` 1.763×, `horner_pure_li` 8.600× |
| `compiler-studio-plan-gates.sh` | 1 | Tier-0 `li-tests`: 207 pass / **8 fail** |
| `lic-workspace-build.sh` | 0 | All workspace smokes green (31 members) |

## WP1 (list/dict runtime) — still blocked

Wave A **not closed**: **G-*** remain **Partial** (not Done). Do not start WP1 stdlib ADT runtime until:

1. **G-math** — `LI_TIER1_PERF_STRICT=1` green (`matmul_blocked`, `horner_pure_li`).
2. **G-lean / default certificate** — workspace + tier-0 corpora build without open VCs on shipped paths.
3. **G-par** — iteration-independence Lean specs (7d-c), not only policy `_par*` slice.
4. **Tier-0 hygiene** — `verify_ok` / `compile_ok` failures in `contracts_verify`, `math_linalg`, `physics`, `encapsulation`, `bytes`.

See [wave-a-stdlib-unblock-checklist.md](../ecosystem/wave-a-stdlib-unblock-checklist.md).
