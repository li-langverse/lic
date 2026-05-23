# Whitepaper: `simd_dot` fast-math DCE incident (2026-05-22)

## 1. The bug (one sentence)

We shipped a **pure-Li** tier-1 `simd_dot` benchmark that **compiled and ran** but, under **`lic build --release -O3 -ffast-math`**, LLVM **eliminated essentially all floating-point work**; the process still exited 0 and printed checksum **`0`** in **~1 ms** instead of the normative **`~3.4×10⁵`** in **~50–100 ms**.

This document targets that bug: what we coded, what the toolchain produced at runtime, which step failed, and the exact inputs/outputs at each stage.

---

## 2. Normative specification (definition of “correct”)

**Benchmark:** `simd_dot` (tier-1 micro).  
**Authority:** `benchmarks/tier1_micro/simd_dot/common/dot_core.c` and `benchmarks/harness/reference.py` (`dot_spec_sum`).

| Field | Value |
|--------|--------|
| **Problem size** | `N = 10_000_000` |
| **Input (implicit)** | Index `i ∈ [0, N)` |
| **Init** | `a[i] = (i & 255) × 0.001`, `b[i] = ((i × 7) & 255) × 0.002` (float64) |
| **Compute** | `acc = Σᵢ a[i] × b[i]` |
| **Output (checksum)** | One float64 printed as `%.17g` |
| **Expected checksum (full N)** | `340367.6243199876` (order of magnitude **≥ 3×10⁵**, **not** 0) |
| **Expected wall time (order)** | Tens of ms on typical dev CPU for the full heap kernel (native reference) |

**Native reference program**

- **Build:** `clang -O3 -march=native -ffast-math cpp/main.c common/dot_core.c -lm`
- **Run (verify):** `./simd_dot_native --verify`
- **Stdout (observed, correct):** `340367.6243199876`
- **Wall time (observed, correct):** ~0.05–0.1 s

---

## 3. What we coded (pure-Li driver)

**Source:** `benchmarks/tier1_micro/simd_dot/li/main.li` (`li_pure=True` in harness — **no** `LI_EXTRA_C` / `dot_core.c` linked into the Li binary).

**Intent:** Same math as `dot_core.c`, exploiting period-256 init: each residue class `r` appears exactly `39062` times in `0..N-1`, plus a tail of `128` residues.

**Build (harness):**

```text
lic build benchmarks/tier1_micro/simd_dot/li/main.li \
  -o simd_dot_li \
  --allow-open-vc --no-lean-verify \
  --release -O3 -ffast-math -march=native
```

**Core logic we wrote** (LUTs + nested loops + sink):

```text
acc ← 0
for chunk in 0 .. 39061
  for off in 0 .. 255
    acc ← acc + dot_lut_a(off) * dot_lut_b7(off)   # float64 LUTs, spec-aligned residues
for off_tail in 0 .. 127
  acc ← acc + dot_lut_a(off_tail) * dot_lut_b7(off_tail)
li_rt_volatile_sink_f64(acc)   # observable sink for harness
return 0
```

- `dot_lut_a(r)` ≡ `(r & 255) × 0.001`
- `dot_lut_b7(r)` ≡ `((r × 7) & 255) × 0.002`
- **Total multiply-adds in source:** `39062×256 + 128 = 10_000_000` (matches `N`)

**Harness read path for pure-Li** (`benchmarks/harness/bench.py`):

```text
LI_PRINT_SINK_F64=1 ./simd_dot_li
→ last line of stdout = checksum
→ wall time measured around that invocation
```

**`li_rt_volatile_sink_f64`** (`runtime/li_rt.c`): stores `v` in a `volatile double` and, when `LI_PRINT_SINK_F64=1`, also `printf("%.17g\n", v)`.

---

## 4. End-to-end pipeline (steps)

| Step | Actor | Input | Output / effect |
|------|--------|--------|------------------|
| **S1** | Engineer | Li source above | `main.li` on disk |
| **S2** | `lic` | `main.li`, `--release -O3 -ffast-math` | LLVM IR / object code for `main` + runtime |
| **S3** | **LLVM** (`-O3`, `-ffast-math`) | IR for hot loops + LUT calls | Optimized machine code (see §5 — **failure here**) |
| **S4** | OS / CPU | Run `simd_dot_li` with `LI_PRINT_SINK_F64=1` | Process exit 0, stdout checksum, wall time |
| **S5** | Harness `verify_benchmark_results` | Stdout + elapsed time | Pass / fail vs `reference.py` |

**What we expected at S4**

| Quantity | Expected |
|----------|----------|
| Exit code | `0` |
| Stdout (last line) | `340367.6243199876` (within `rtol=2e-8` of spec) |
| Wall time | **≥ 0.01 s** (`min_li_seconds` in `reference.py`) |

**What we observed at S4 (incident build)**

| Quantity | Expected | **Observed (bug)** |
|----------|----------|---------------------|
| Exit code | `0` | `0` |
| Stdout checksum | `~340367.62` | **`0`** |
| Wall time | ≥ ~0.01 s (sanity floor) | **~0.001 s** (~100× too fast) |

**Comparison row (same flags, same spec)**

| Binary | Source | S3 flags | S4 checksum | S4 wall time |
|--------|--------|----------|-------------|--------------|
| `simd_dot_native` | `dot_core.c` | `-O3 -ffast-math` | `340367.6243199876` | ~0.05–0.1 s |
| `simd_dot_li` (incident) | `main.li` pure | `-O3 -ffast-math` via `lic` | **`0`** | **~0.001 s** |

So the bug is **not** “program crashed” or “wrong formula in the Li text we intended.” The bug is: **S3 produced a binary that did not perform the spec work, yet S4 still looked like a successful benchmark run.**

---

## 5. Where it went wrong (exact failure step)

**Failure step: S3 — LLVM optimization under `-ffast-math`, not S1 (source design).**

1. **Source (S1–S2)** expressed a full reduction over 10M terms with a **single** `li_rt_volatile_sink_f64(acc)` at the **end**.
2. **LLVM (S3)** with fast-math may treat intermediate LUT results and partial sums as **provably zero**, **unused**, or **foldable** across the nested loops, because:
   - `-ffast-math` relaxes FP observability (reassociation, reciprocal approximations, “no NaNs” style assumptions).
   - No **per-iteration** or **per-tile** side effect forced the 10M multiply-add chain to stay live—only the final `acc` reached a `volatile` store.
3. **Resulting machine code (S3 output)** effectively computed **`acc = 0`** (or never executed the hot loops), so **S4 output** was checksum **`0`** in **~1 ms**.

**Not the failure**

| Claim | Verdict |
|--------|---------|
| “We coded the wrong dot formula in Li” | **No** for the LUT driver: residues match `dot_spec_sum`; isolated `dot_lut_a(42)` still returned `0.042`. |
| “LLVM is broken / non-conforming” | **No** for this incident: behavior is consistent with **aggressive legal optimization** given our flags and weak observability. |
| “Native C is wrong” | **No**: native matched spec and reproducible checksum. |

**Contrast (why `horner_pure_li` did not fully DCE away)**  
`horner_pure_li/li/main.li` uses a tight `acc = acc * x + 1.0` recurrence; the volatile sink on the **final** `acc` was enough there, and verify adds a **min wall-time** guard (`min_li_seconds`). `simd_dot` showed that **end-only sink + fast-math + large foldable LUT loops** was **not** sufficient.

---

## 6. Earlier wrong implementation (separate from DCE)

Before the LUT driver, an **array-tile** pure-Li variant (`800 × array[40000]` with `a @ b`) used **different effective init/reduction** than `dot_core.c`.

| Stage | S4 checksum | Verdict |
|--------|-------------|---------|
| Early pure-Li tiles | **~64** | Wrong vs spec — **caught** by Li vs native verify |
| LUT pure-Li (aligned counts) | **0**, ~1 ms | Wrong vs spec — **DCE / over-optimization**, not wrong LUT table entries |

That progression matters: verify first caught **wrong math**; later we caught **no math**.

---

## 7. Why our old checks missed or under-weighted it

**Check we had:** Li checksum vs native `--verify`.

| Failure mode | Li vs native only | Spec + `|checksum|` floor + `min_li_seconds` |
|--------------|-------------------|-----------------------------------------------|
| Li wrong (≈64), native right | Fail | Fail |
| Li DCE → 0, native right | Fail | Fail |
| Li DCE → 0, native also broken | **Pass** | Fail |
| Both wrong same way | **Pass** | Fail |

**Lesson:** exit 0 + “a number printed” is not verification. **S5 must compare to the normative spec and timing floors**, not only to another binary.

---

## 8. What we changed after the incident

1. **`benchmarks/harness/reference.py`** — `dot_spec_sum`, `TIER1_REFERENCE["simd_dot"]` with `min_abs_full=300_000`, `min_li_seconds=0.01`.
2. **`verify_benchmark_results`** — native and Li vs spec; pure-Li timing guard; `LI_PRINT_SINK_F64` path documented.
3. **`scripts/verify-math-physics-goldens.sh`** — small-N library goldens.
4. **Policy** — `.cursor/rules/li-benchmark-correctness.mdc`: DCE allowed; **verified** result required before claims.

**Compiler / product follow-ups (open)**

- Per-tile or per-reduction volatile/noinline boundaries for pure-Li dot until end-only sink is proven safe under `-ffast-math`.
- Do not publish pure-Li `simd_dot` throughput until verify shows spec checksum **and** realistic wall time.

---

## 9. Fault summary (for external reporting)

| Layer | Responsibility |
|--------|----------------|
| **Li source math (LUT driver)** | Intended to match spec; **not** the root cause of checksum `0`. |
| **LLVM + `-ffast-math`** | Optimized away unobserved work; **expected** given flags, not a compiler “bug.” |
| **Our harness / contract** | **Root cause:** insufficient observability in the compiled benchmark + insufficient verification before trusting timings. |

**Say:** “Our pure-Li benchmark did not keep the reduction observable under release fast-math; LLVM eliminated it. We fixed verification, not the definition of the dot product.”

**Do not say:** “LLVM bug” or “we implemented the wrong dot formula” (for the LUT incident).

---

## 10. References in repo

| Artifact | Path |
|----------|------|
| Normative C kernel | `benchmarks/tier1_micro/simd_dot/common/dot_core.c` |
| Pure-Li driver | `benchmarks/tier1_micro/simd_dot/li/main.li` |
| Spec / floors | `benchmarks/harness/reference.py` |
| Build + verify | `benchmarks/harness/bench.py` |
| Volatile sink | `runtime/li_rt.c` (`li_rt_volatile_sink_f64`) |
| Policy | `.cursor/rules/li-benchmark-correctness.mdc`, `benchmarks/results/README.md` |
