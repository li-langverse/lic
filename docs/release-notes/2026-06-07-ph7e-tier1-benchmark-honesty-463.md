# PH-7e tier-1 benchmark honesty (#463)

## Summary

Align **G-math** and master-plan tier-1 perf wording with dashboard-measured ratios. Retract overstated “closed slice (tier-1): `matmul_naive`, `horner_pure_li` ≤1.2×” claims that drifted from the 2026-05-29 audit.

## Evidence

| Source | Result |
|--------|--------|
| `benchmarks/data/latest/ecosystem-audit.json` (ingest 2026-06-01) | red `[]`; six `#463` ids green |
| `./scripts/check-tier1-li-vs-cpp.sh` on `tier-tier1.csv` (2026-06-07) | all four pure-Li math microbenches ≤1.2× |

## Changed

| Path | Change |
|------|--------|
| `docs/verification/provability-gaps.md` | Honest G-math tier-1 advisory row with measured ratios |
| `docs/superpowers/plans/2026-05-14-li-master-plan.md` | Phase 7e tracker cites dashboard green + `#463` |
| `docs/superpowers/plans/2026-05-16-li-math-linalg-surface.md` | Exit gate checked with bench evidence |
| `docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md` | 7e-b + tier-1 perf gate updated |
| `docs/superpowers/plans/2026-05-30-ph7e-tier1-red-benchmark-honesty.md` | Sub-phases F/G status |

## Verify

```bash
BENCHMARKS_ROOT=../benchmarks LI_TIER1_PERF_CSV=../benchmarks/results/tier-tier1.csv ./scripts/check-tier1-li-vs-cpp.sh
./scripts/check-doc-provability-claims.sh
./li-tests/tooling/tier1_li_vs_cpp.sh
```
