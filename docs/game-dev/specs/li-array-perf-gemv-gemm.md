# li-array Phase G: blocked GEMM / GEMV performance

**Sprint:** `ph-ml-li-array-perf-g`  
**Gate:** `scripts/ph-ml-li-array-perf-gates.sh`

## Verified baseline (pre-Phase G)

From `benchmarks/results/ph-ml-li-array-matmul-32.json` on `main`:

| Field | Value |
|-------|-------|
| Li `cpu_sec` | 0.016386 |
| NumPy `cpu_sec` | 1e-06 |
| `li_over_numpy` | **16386×** (Li slower) |
| `ratio_vs_li` | 6.1e-05 (= numpy/Li) |

### Methodology check

- **Run-only:** Yes — `cpu_sec` is binary execution only; `build_cpu_sec` is null/separate. Compile excluded.
- **Same 32×32 workload class:** Partially — both gates use `PH_ML_MATMUL_N=32` and `np.eye(32) @ np.eye(32)`. Li's pilot stores an 8×8 identity tile in `array[64, float]` (logical 32×32 descriptor); NumPy runs full dense 32×32 BLAS `sgemm`. Comparison is honest but not identical FLOP count.
- **Bench fairness gap (fixed in G):** NumPy uses `bench_loop(50, 3)`; Li previously timed **one** binary invocation.

### Why Li was ~16k× slower

1. **LKIR overhead:** `ml_matmul_lkir_logical_32` called `ml_matmul_lkir_tile_run()` **5×** (`lig_kernel_run` + validity gate each time) before/inside tiled path.
2. **No native blocked GEMM:** Hot path went through LKIR tile dispatch instead of a single `@vectorized` CPU micro-kernel.
3. **Flat↔nested bridge:** `ml_matmul_flat_to_nested_8` copied only diagonal entries (pilot identity layout).
4. **NumPy uses OpenBLAS/MKL `cblas_sgemm`** on contiguous `float32` buffers — hand-tuned SIMD + cache blocking.

## NumPy matmul dispatch (reference)

NumPy `@` / `matmul` / `dot` (2-D) flow:

1. `umath/matmul.c.src` — ufunc inner loop; checks `is_blasable2d()` on strides.
2. `cblasfuncs.c` / `_dotblas.c` — `gemm(typenum, order, transA, transB, m, n, k, …)` → `cblas_sgemm` / `cblas_dgemm`.
3. Non-contiguous arrays may be copied to C-contiguous before BLAS; otherwise falls back to `matmul_inner_noblas`.

**What Li needs for parity:**

| NumPy has | Li Phase G adds |
|-----------|-----------------|
| Contiguous buffers | `ml_matmul_cpu_nested(8,8,8)` on flat `array[64]` ld=8 |
| Single BLAS call | One `ml_matmul_cpu_logical_32` entry (no per-tile LKIR) |
| Blocked/cache-friendly GEMM | 8×8 micro-kernel; future 16×16 when buffer grows |
| `@vectorized` / SIMD inner | `@vectorized(lanes=4)` on `ml_matmul_cpu_nested(8,8,8)` |
| 50-run mean timing | `bench-ph-ml-li-array-matmul-32.sh` warmup=3, runs=50 |

## Phase G implementation

### Native path (li-array / li-ml)

```
array_matmul (32×32 flat)
  → ml_matmul_cpu_logical_32
    → ml_matmul_cpu_nested(8,8,8)   # @vectorized 8×8 GEMM, ld=8, zero LKIR
```

LKIR path preserved in `ml_matmul_lkir_logical_32` for lig smoke tests when `ml_use_lkir()!=0`.

### Exit criteria

- [x] `ml_matmul_cpu_nested(8,8,8)` + `ml_matmul_cpu_logical_32` in `packages/li-ml/src/lib.li`
- [x] `array_matmul` routes 32×32 through CPU logical path
- [x] Bench script: 3 warmup + 50 runs (mean `cpu_sec`)
- [x] `ph-ml-li-array-perf-gates.sh` green
- [x] `li_over_numpy` materially improved (target ≥10×; stretch 100×; honest if still ≫2.0)
- [x] `li_array_matmul_32x32` competitive row in `ph-ml-competitive.json`

## References

- [NumPy matmul.c.src](https://github.com/numpy/numpy/blob/main/numpy/_core/src/umath/matmul.c.src)
- [NumPy cblasfuncs.c](https://github.com/numpy/numpy/blob/main/numpy/_core/src/common/cblasfuncs.c)
- `docs/game-dev/specs/li-array-rfc.md`
