# li-array Phase H: OpenBLAS BLAS hook

**Sprint:** `ph-ml-li-array-perf-h`  
**Gate:** `scripts/ph-ml-li-array-perf-h-gates.sh`  
**Prior:** `docs/game-dev/specs/li-array-perf-gemv-gemm.md` (Phase G)

## Problem

Phase G reduced `li_over_numpy` from ~16386× to ~343× by dropping LKIR from the 32×32 hot path and using a single `@vectorized` 8×8 nested GEMM. NumPy still wins because it calls OpenBLAS/MKL `cblas_sgemm` on contiguous buffers.

## Phase H design

### Runtime (`runtime/li_rt_blas.c`)

- Enable with `LI_ARRAY_BLAS=openblas` (or `1`, `auto`; disable with `0` / `off`).
- `dlopen` `libopenblas.so.0` / `libopenblas.so` (or Windows `.dll` variants).
- Resolve `cblas_dgemm` (Li `float` codegen is f64); row-major `C = A·B` with shared leading dimension `ld`.
- Skip BLAS when `m·n·k < 4096` — OpenBLAS fixed cost loses to `@vectorized` 8×8 CPU on the pilot tile.
- No link-time `-lopenblas` — CI and dev machines without OpenBLAS keep Phase G fallback.

### Li dispatch

```
li_array_matmul (32×32 flat)
  → ml_matmul_cpu_logical_32
      → ml_blas_matmul_f32(8,8,8,8,…) when li_rt_blas_sgemm_ready()==1
      → else Phase G nested 8×8 GEMM
```

Explicit API: `li_array_matmul_blas_f32` (RFC Phase F follow-up).

### Pilot buffer note

Current `array[64, float]` pilot stores an 8×8 identity tile with logical 32×32 `ArrayDesc`. BLAS is invoked as 8×8×8 with `ld=8` matching the actual FLOPs until the buffer cap rises (Phase I/J).

## Env vars

| Variable | Values | Effect |
|----------|--------|--------|
| `LI_ARRAY_BLAS` | `openblas`, `1`, `auto` | Try dlopen OpenBLAS before CPU nested path |
| `LI_ARRAY_BLAS` | `0`, `off` | Force Phase G CPU path |
| `LI_ARRAY_GEMM_TILE` | (Phase I) | Tile sweep override |

## Bench metadata

`bench-ph-ml-li-array-matmul-32.json` adds:

- `blas_backend`: `openblas` \| `none`
- `workload_class`: `blas_labeled` when OpenBLAS used

## Exit criteria

- [x] Runtime hook + Li dispatch wired
- [x] Gate script green; warn when `li_over_numpy > 2.0`
- [ ] Phase I tile sweep
- [ ] Phase J fair 32×32 dense buffer + `ratio_target_met ≤ 2.0`

## References

- `docs/game-dev/specs/li-array-rfc.md` — Phase F BLAS parity path
- `runtime/li_rt_tls.c` — dlopen pattern
- NumPy `cblasfuncs.c` → `cblas_sgemm`
