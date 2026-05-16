# Fast math and parallelism

!!! note "Status"
    User-facing **math notation** (`A @ B`, no manual `simd`) is **planned** (Phase 2i/7e). **Decorators** parse but do not elaborate yet. Parallel disjointness uses **heuristic** checks today. See **[Provability gaps](../verification/provability-gaps.md)**.

Li is built for **scientific and high-performance** work. Two features matter most:

1. **SIMD** — do the same operation on several numbers in one step (vector lanes).
2. **`parallel for`** — use many CPU cores with proof that threads do not corrupt shared memory.

You do **not** install NumPy, OpenMP bindings, or a thread library yourself — Li’s compiler wires native vector instructions and (on Linux) OpenMP when your program passes the proof gate.

---

## Vector types (`simd`)

A SIMD value is a small bundle of numbers that move together:

```nim
var v: simd[f64, 4] = __li_simd_splat_f64(1.5)
```

| Piece | Meaning |
|-------|---------|
| `simd[f64, 4]` | Four `float64` lanes in one value |
| `__li_simd_splat_f64(x)` | Copy one scalar into all four lanes |

### Operations (v1 intrinsics)

| Call | Effect |
|------|--------|
| `__li_simd_splat_f64(x)` | Broadcast scalar to all lanes |
| `__li_simd_mul_f64(a, b)` | Lane-wise multiply |
| `__li_simd_add_f64(a, b)` | Lane-wise add |
| `__li_horiz_sum_f64(v)` | Add all lanes into one `float` |

Example kernel (from the `simd_dot` benchmark):

```nim
var v: simd[f64, 4] = __li_simd_splat_f64(x)
var w: simd[f64, 4] = __li_simd_splat_f64(x)
var p: simd[f64, 4] = __li_simd_mul_f64(v, w)
acc = acc + __li_horiz_sum_f64(p)
```

Lane counts **4 and 8** are supported in the current compiler; other sizes are rejected at compile time.

---

## Parallel loops

```nim
parallel for j in 0..<8
  requires disjoint_elem(j, buf)
  decreases 8 - j
=
  buf[j] = 0.0
```

| Piece | Meaning |
|-------|---------|
| `parallel for` | Run iterations on multiple cores |
| `0..<8` | `j` runs 0, 1, …, 7 |
| `requires disjoint_elem(...)` | **Proof obligation**: each iteration touches different memory |
| Body | What each iteration does |

If Li cannot see that iterations are independent, **`lic build` fails**. That is how Li prevents data races by default.

### Thread count

```bash
lic build sim.li -o sim --threads=8
```

Or set `LI_OMP_THREADS=8` in the environment before running the binary (Linux with OpenMP linked).

---

## Putting it together

A tiny simulation might:

1. Store fields in `array[N, float]`.
2. Zero forces with `parallel for` (disjoint writes per index).
3. Update inner physics with scalar or SIMD loops.

See `benchmarks/tier2_physics/md_lennard_jones/li/main.li` for a pure-Li driver example in the repository.

---

## What is not allowed (on purpose)

| You cannot… | Why |
|-------------|-----|
| Share one variable across parallel iterations without proof | Data races |
| Mix `int` and `float` silently | Catches science bugs |
| Skip `requires` / `ensures` / `decreases` | No proof without promises |
| Use `Any` or `unsafe` | Breaks the guarantee story |

More detail: [SIMD & parallel reference](../language/simd-parallel.md).
