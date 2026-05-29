# Tier-1 matmul bench improver (2026-05-29)

## Problem + SOTA

Tier-1 `matmul_naive` (256³ IKJ) and `matmul_blocked` (512³, BK=64) were **red** on the public dashboard (`ratio_vs_cpp` 1.33× and 1.55× vs 1.2× cap). C++ oracles use `benchmarks/tier1_micro/*/common/*_core.c` (scalar IKJ / cache-blocked IKJ).

**Learned from**

| Source | Takeaway |
|--------|----------|
| BLIS / Goto & van de Geijn | IKJ + cache blocking for GEMM micro-kernels |
| LLVM `-ffast-math` + `llvm.fmuladd` | FMA accumulation in hot loops (`emit_matmul2d_ijk_loops`) |
| Li PH-7e (`ArrayMatMul2DF64`) | Lower `@` / assign matmul to MIR instead of scalar `while` nests |
| Org oracle `matmul_*_core.c` | Init + single GEMM + checksum; no repeated `@` tiles in timed path |

## Quality table

| Axis | matmul_naive | matmul_blocked |
|------|--------------|----------------|
| **Stability** | unchanged — checksum vs iterative oracle | unchanged |
| **Speed (local)** | 1.33× → **1.00×** cpp | 1.29× → **1.24×** cpp (advisory; still >1.2×) |
| **Accuracy** | no change (same init + GEMM semantics) | no change |
| **Memory** | n/a | n/a |

Dashboard before (ingested `summary.json` 2026-05-29): li/cpp wall_time 0.0036/0.0027 (naive), 0.0158/0.0102 (blocked).

Local after (`benchmarks/results/latest.csv`): li/cpp 0.0019/0.0019 (naive), 0.0110/0.0089 (blocked).

## Commands

```bash
./scripts/build.sh
export LIC="$PWD/build/compiler/lic/lic"
python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 30
./scripts/check-tier1-li-vs-cpp.sh
# benchmarks repo ingest (human/CI):
# LIC_ROOT=<lic> ./scripts/ingest/ingest-lic.sh
```

## Changed

| Path | Why |
|------|-----|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | `C = A @ B` → `ArrayMatMul2DF64` + FMA codegen |
| `compiler/mir/include/li/mir.hpp` | `matmul_c_prezeroed` on assign `@` |
| `compiler/mir/lower.cpp` | set `matmul_c_prezeroed` for `C = A @ B` |
| `compiler/codegen/emit.cpp` | skip redundant C zero; `AlwaysInline` on `mm_lut_*` |

## North star

**Domain:** HPC tier-1 micro / PH-5b, PH-7e — proof-before-perf; no `unsafe` shortcuts.
