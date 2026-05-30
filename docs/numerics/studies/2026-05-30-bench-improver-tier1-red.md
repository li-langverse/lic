# Bench improver — tier-1 red rows (2026-05-30)

**north_star_fit:** blazingly-fast — PH-5b, PH-7e tier-1 pure-Li micro kernels  
**Agent:** bench_improver · **heap:** coord_numerics

## Problem

Public dashboard showed **red** `horner_pure_li` at **3.0×** cpp (`benchmarks/results/latest.csv` @ lic `012becef`). Preflight audit listed six reds; live harness on `11ef5e37` shows most cleared; **`horner_pure_li` red was stale ingest + cold lic binary**.

## SOTA / Learned from

| Source | Takeaway |
|--------|----------|
| LLVM `llvm.fmuladd` + blocked IKJ (BLIS-style) | Tier-1 `@` uses `ArrayMatMulBlocked2DF64` with tile size 64 |
| Prior lic study `2026-05-30-matmul-blocked-7e.md` | Tile-origin bug caused bogus fast Li; 4-wide inner-`j` FMA required |
| Horner PH-7e (`HornerConstLoopF64` @ trip≥65536) | Pure-Li `acc = acc*x+1` lowers to chunked FMA when `x` is const |

## Quality table

| Axis | Before (dashboard) | After (local tier-1, 6-run median) |
|------|-------------------|--------------------------------------|
| **Speed** `horner_pure_li` | 3.0× red | **0.8–1.0×** green |
| **Speed** `matmul_blocked` | briefing 1.55× (stale) | **1.30×** advisory gap (still >1.2×) |
| **Speed** `matmul_naive` | briefing 1.33× (stale) | **1.06×** green |
| **Stability** | tier-0 unknown on runner | unchanged — no tolerance edits |

## Codegen

- Merged `e6fcf17f` matmul emit (`gather`/`scatter` 4-wide FMA, manual blocked IKJ loops, tile `kk`/`jj` reset) into `compiler/codegen/emit.cpp`, preserving `runtime_team_size` API.
- **Open:** `matmul_blocked` still ~1.30× on `11ef5e37` + emit merge; full `perf/bench-improver-matmul-simd-j-20260530` branch measured **0.98×** — likely needs aligned `lower.cpp` / MIR path from same branch stack.

## Commands

```bash
cd lic && ./scripts/build.sh
cd lic/benchmarks/harness && python3 bench.py --tier 1 --runs 6
cd lic && ./scripts/check-tier1-li-vs-cpp.sh

cd benchmarks
cp ../lic/benchmarks/results/latest.csv results/latest.csv
LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## CSV evidence (lic `benchmarks/results/latest.csv`)

| benchmark | cpp (s) | li (s) | ratio |
|-----------|---------|--------|-------|
| `horner_pure_li` | 0.0005 | 0.0004 | **0.80×** |
| `matmul_naive` | 0.0018 | 0.0019 | 1.06× |
| `matmul_blocked` | 0.0086 | 0.0112 | **1.30×** |
| `simd_dot` | 0.0176 | 0.0179 | 1.02× |
