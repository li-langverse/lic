# RFC: li-array — strict-shape arrays for competitive ML

**Status:** pilot (Phase A landed)  
**Package:** `lic/packages/li-array` (`import array`)  
**Gate:** `scripts/ph-ml-li-array-gates.sh`  
**Goal sprint:** `data/goal-directed-sprints/ph-ml-li-array-competitive.md`

## Problem

Li ML today uses ad-hoc `MlTensorDesc` + raw `array[64, float]` buffers in `li-ml`. That works for tiled matmul pilots but lacks:

1. A documented, strict shape algebra (NumPy-style silent broadcasting is **rejected**).
2. A single descriptor type for elementwise ops, reductions, and matmul bridges.
3. A competitive bench path where compile time is excluded and 32×32+ sizes are measured fairly vs NumPy/BLAS.

NumPy’s “unmathematical broadcasting” (e.g. `(4,4) + (4,1)` → `(4,4)` without explicit agreement) hides shape bugs and complicates proof discharge. Li’s move semantics and fixed-rank `array[M, T]` / `array[M, array[N, T]]` types favor **explicit** shapes.

## Design principles

| Rule | Li behavior | NumPy (rejected) |
|------|-------------|------------------|
| Elementwise binary ops | `array_shape_equal(a, b) == 1` or **error (return 0)** | Silent broadcast of size-1 axes |
| Matmul / dot | 2D only: `a.shape1 == b.shape0`; ranks must match | `np.dot`/`@` with 1-D promotion |
| Reductions | Operate on explicit `ArrayDesc` element count | `axis=` with keepdims broadcast back |
| Storage | Pilot: flat `array[64, float]` + optional nested 8×8 for LKIR | Opaque strided buffer |
| Dtype | Pilot: `f32` only | Mixed promotion |

**No silent 1-dim expansion.** If users need outer products or broadcast-add, they must call an explicitly named op (future `array_broadcast_add` with documented semantics) — not overload `array_add`.

## Nested vs flat storage

### Flat (pilot default: `array_storage_flat()`)

- **Pros:** Matches `ml_matmul_flat_idx`, BLIS/NumPy row-major layout, single buffer for competitive timing, simpler move semantics (one `var array[64, float]` per tensor).
- **Cons:** Li compiler currently requires **constant** indices for many flat accesses; dynamic `(m,n,k)` loops use nested 8×8 tiles in `li-ml` today.

### Nested (`array[M, array[N, T]]`)

- **Pros:** Natural `@vectorized` inner loops, Lean `LiArray (LiArray Float m) n` proofs (`Discharge.lean`), LKIR tile micro-kernel path (`ml_matmul_cpu_nested`).
- **Cons:** Two-level indexing; harder to match BLAS leading-dimension layout; not ideal for large contiguous GEMM.

**Recommendation (Phase B–C):** Public API accepts `ArrayDesc` + flat buffer; matmul dispatches to `ml_tensor_matmul_64` (flat→nested bridge inside `li-ml`). Nested buffers exposed only via `array_matmul_nested` for LKIR tile parity. When lic gains non-constant flat indexing, migrate hot paths to flat-only and retire nested bridge except for GPU tiles.

## How JAX / BLIS avoid broadcast confusion

- **JAX:** `jnp.matmul` requires conformable ranks; broadcasting applies to **batch** dimensions only when explicitly using `vmap` or `einsum` with named axes — not silent NumPy rules on core `@`.
- **BLIS:** GEMM is `(m×k)·(k×n)` with explicit leading dimensions; no elementwise broadcast in BLAS API.
- **li-array alignment:** Treat batch dims as explicit rank-3+ `ArrayDesc` in Phase D; until then rank ≤ 2 and strict equality for elementwise ops.

## Integration with li-ml

| li-array | li-ml bridge |
|----------|--------------|
| `ArrayDesc` | Superset of `MlTensorDesc` (rank + shape[4] + storage) |
| `array_matmul` | `ml_tensor_matmul_64` → `ml_matmul_tiled_dynamic` → LKIR |
| `array_matmul_nested` | `ml_tensor_matmul_nested` → `ml_matmul_cpu_nested` |
| `array_max_dim()` | `ml_matmul_max_dim()` (32 pilot) |

**Migration:** `MlTensorDesc` remains for backward compat; new code uses `ArrayDesc`. Phase E deprecates direct `MlTensorDesc` in smokes in favor of `import array`.

## API sketch

```li
import array

type ArrayDesc = object   # rank, shape[4], dtype, storage, ld
type LiArray = object     # desc only; buffers passed separately (move semantics)

def array_desc_1d(n, storage) -> ArrayDesc
def array_desc_2d(rows, cols, ld, storage) -> ArrayDesc
def array_shape_equal(a, b) -> int          # 1 = equal, 0 = reject
def array_matmul_shape_ok(a, b) -> int      # 2D conformable only

def array_add(a, af, b, bf, c) -> int        # strict same shape
def array_sum(desc, buf) -> float
def array_matmul(a, af, b, bf, c) -> int    # ml LKIR bridge
```

## Competitive path (`ratio_vs_li` vs NumPy)

1. **Exclude compile:** Bench scripts build once, time `perf_counter` around binary only (`bench-ph-ml-lkir-matmul-32.sh` pattern).
2. **Minimum size:** 32×32×32 logical GEMM (Wave 13 T6 baseline); extend to 64×64 when `array_max_dim` rises.
3. **Validity gate:** Parity smoke must pass before timing row is `executed: true`.
4. **Target:** `ratio_vs_li ≤ 2.0` vs NumPy CPU @ 32×32 (Phase F); stretch ≤ 1.0 with OpenBLAS-linked reference disclosure.

## Li compiler constraints

- **Move semantics:** Descriptors are small `object` copies; large data stays in caller-owned `var array[64, float]`.
- **`@vectorized`:** Inner dot loops in `ml_matmul_cpu_nested` use `@vectorized(lanes=4)`; li-array elementwise add/sum use scalar loops in pilot (Phase C may vectorize).
- **Prelude:** No prelude matmul yet; `@` operator on arrays is **not** in scope — use `array_matmul`.
- **Proofs:** `array_shape_equal` and `array_matmul_shape_ok` are discharge-friendly (integer comparisons only).

## Phases (see goal file)

| Phase | Deliverable |
|-------|-------------|
| A | Package + RFC + strict smokes (this PR) |
| B | Flat dynamic indexing when lic allows; drop nested bridge on CPU hot path |
| C | `@vectorized` elementwise + sum |
| D | Rank-3 batch matmul without broadcast |
| E | Replace `MlTensorDesc` in li-llm forward |
| F | 32×32+ competitive row via `array_matmul` + gate |

- **Competitive benches:** Run matmul timing in a **fresh process** after LKIR prologue; elementwise smokes run before matmul in gate order because `lig_kernel_run` global state can clobber flat buffers in-process (Phase F isolates via separate binary invocation per bench row).

- Runtime `ArrayBuffer` type vs compile-time `array[N, float]` caps — deferred until lic supports heap tensors.
- GPU `array` device buffer — reuse `li-gpu` + `@gpu` from `ArrayDesc` metadata (Phase D+).

## References

- `docs/game-dev/specs/ml-tensor-pilot-rfc.md` — prior `MlTensorDesc` pilot
- `packages/li-ml/src/lib.li` — `ml_matmul_tiled_dynamic`, LKIR bridge
- `docs/semantics/Discharge.lean` — nested `LiArray` proofs
- `scripts/bench-ph-ml-lkir-matmul-32.sh` — competitive timing pattern
