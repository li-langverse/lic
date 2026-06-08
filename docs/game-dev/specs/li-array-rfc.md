# RFC: li-array — typed ndarray surface (PH-ML competitive foundation)

**Status:** pilot (Stage A)  
**Package:** `packages/li-array` (`import array`)  
**Replaces:** ad-hoc `MlTensorDesc` in `li-ml` over time  
**Gate:** `scripts/ph-ml-li-array-gates.sh`

## Problem

`li-ml` carries a minimal `MlTensorDesc` (rank, rows, cols, ld) with hand-rolled flat↔nested
bridges for 4×4 and 8×8 tiles. There is no shared broadcast policy, no stride-aware views, and
matmul paths duplicate shape checks. Competitive ML benches need a single array abstraction that
can grow toward BLAS parity without NumPy-style silent promotion.

## Design principles

1. **Math-first, explicit shapes** — same policy as [linear-algebra.md](../../language/linear-algebra.md) and master plan **2i**: no silent rank promotion.
2. **Mathematically valid broadcasting only** — trailing-dimension NumPy rules where one side is 1 or sizes match; reject all other pairs at compile time (language) or via `li_array_broadcast_compatible()` (library views).
3. **Matmul never broadcasts** — inner dimensions must match exactly; batch/leading dims require explicit batch APIs later.
4. **Flat tile + nested micro-kernel** — `ArrayDesc` describes logical shape/strides; storage is either flat (`array[64, float]` + ld) or nested (`array[8, array[8, float]]`) for LKIR tiles.

## NumPy broadcasting — what Li allows vs rejects

| Case | NumPy | Li compiler (today) | li-array (pilot) |
|------|-------|---------------------|------------------|
| `array[N] op array[N]` | OK | OK | OK (exact match) |
| `array[1] op array[N]` | OK (len-1) | OK | OK (`li_array_broadcast_dim_ok`) |
| `array[2] op array[4]` | error | compile_fail | **reject** (returns 0) |
| `array[M,N] op array[M,N]` | OK | OK when static equal | OK |
| `array[1,N] op array[M,N]` | OK | not in compiler yet | OK (leading 1) |
| `array[M,1] op array[M,N]` | OK | not in compiler yet | OK (trailing 1) |
| `array[2,3] op array[4,3]` | error | compile_fail | **reject** |
| `A @ B` inner mismatch | error | compile_fail | **reject** (`a.cols != b.rows`) |
| `array[3,1] @ array[1,4]` | OK (broadcast matmul) | not supported | **reject** (explicit batch matmul deferred) |
| Rank mismatch without padding | error | compile_fail | **reject** unless ranks equal after virtual 1-padding |

**Unmathematical broadcasting** (Li rejects): any dimension pair where both sizes exceed 1 and differ (e.g. 2 vs 4, 3 vs 5). This includes NumPy cases that are technically defined but Li treats as errors until explicit batch APIs exist.

## Types (pilot)

```li
type ArrayDesc = object
  public rank: int           # 1 or 2 in pilot
  public rows: int           # dim 0 (or length for 1d)
  public cols: int           # dim 1 (1 for vectors)
  public dtype: int          # li_array_dtype_f32() == 0
  public ld: int             # leading dimension (flat storage)
  public storage: int        # 0=flat, 1=nested tile

def li_array_desc_2d(rows, cols, ld) -> ArrayDesc
def li_array_desc_1d(len) -> ArrayDesc
def li_array_dim_ok(desc) -> int
def li_array_broadcast_dim_ok(a, b) -> int
def li_array_broadcast_compatible_2d(ar, ac, br, bc) -> int
def li_array_matmul_inner_ok(a, b) -> int   # a.cols == b.rows, no broadcast
def li_array_matmul_f32(a, af, b, bf, c) -> int  # delegates ml_tensor_matmul_64
```

## Path to BLAS parity

| Phase | Work | Bench | Status |
|-------|------|-------|--------|
| A | `ArrayDesc`, broadcast guards, 4×4 matmul via `li-ml` | `ph-ml-li-array-matmul.json` | **done** |
| B | Dynamic M/N/K tile loops, stride views | extend competitive row | **done** |
| C | `@vectorized` blocked matmul on flat storage | tier-1 `matmul_blocked` | **done** |
| D | LKIR/GPU tile dispatch from `ArrayDesc` | lig parity gate | **done** |
| E | Batch matmul API (explicit leading dim) | transformer forward | **done** |
| F | BLAS/OpenBLAS reference + run-only 32×32 bench | `ph-ml-li-array-matmul-32.json` `ratio_vs_li` | **done** — see [li-array-perf-gemv-gemm.md](li-array-perf-gemv-gemm.md) |
| G | Blocked CPU GEMM, 50-run mean, drop LKIR from 32×32 hot path | `ph-ml-li-array-perf-gates.sh` | **done** — `li_over_numpy` 16386→710 (23×) |

Run-only timing: bench scripts record `cpu_sec` on binary execution only; `build_cpu_sec` is separate (already in `bench-ph-ml-lkir-matmul.sh`).

## Migration from MlTensorDesc

```li
# today
var d: MlTensorDesc = ml_tensor_desc_2d(4, 4, 8)

# target
var d: ArrayDesc = li_array_desc_2d(4, 4, 8)
# li_array_matmul_f32 internally maps to ml_tensor_matmul_64 until li-ml drops duplicate desc
```

## References

- [ml-tensor-pilot-rfc.md](ml-tensor-pilot-rfc.md)
- [2026-05-22-2i-broadcast-len1.md](../../release-notes/2026-05-22-2i-broadcast-len1.md)
- `li-tests/math_linalg/broadcast_invalid_len2_vs_len4.li`
