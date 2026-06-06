# li-parallel perf gate (WP-PAR-40–43)

Advisory CI gate comparing `li_parallel` vs `li_serial` speedup and vs C++ (`cpp`) wall time on Class A tier1 dual-mode rows.

## Run

```bash
# Fixture (fast, no bench run):
./li-tests/tooling/li_parallel_perf_gate.sh

# After lipar-suite --dual-mode:
export LI_LIPAR_PERF_CSV=benchmarks/results/latest.csv
./scripts/check-li-parallel-perf-gate.sh

# Strict (fail on gaps):
LI_LIPAR_PERF_STRICT=1 ./scripts/check-li-parallel-perf-gate.sh
```

## Thresholds

| Env | Default | Meaning |
|-----|---------|---------|
| `LI_LIPAR_MIN_SPEEDUP` | `1.05` | Min serial/parallel ratio when serial wall ≥ `LI_LIPAR_MIN_WALL_SEC` |
| `LI_LIPAR_MIN_WALL_SEC` | `0.005` | Skip speedup check below this (PR micro-bench noise) |
| `LI_LIPAR_MAX_VS_CPP` | `1.2` | Max li_parallel/cpp ratio (same cap as tier-1 Li vs C++) |

Integrated into `scripts/check-li-parallel-full-suite.sh` after dual-mode row validation.
