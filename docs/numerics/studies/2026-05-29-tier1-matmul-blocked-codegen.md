# Tier-1 `matmul_blocked` — blocked IKJ codegen micro-opt (`tier1-matmul-blocked-codegen`)

**Goal:** Close lic tier-1 red row `matmul_blocked` to ≤1.2× cpp (PH-5b, PH-7e)  
**Agent:** `bench_improver` · **Run:** `bench_improver-1780071596693`  
**North star:** PH-5b (numerics dashboard), PH-7e (math→SIMD lowering)  
**Preflight:** `benchmarks/data/latest/summary.json` @ 2026-05-29T07:01Z · [dashboard](https://li-langverse.github.io/benchmarks/)

---

## Problem

Pure-Li `matmul_blocked` (512×512, BK=64 IKJ) is the **only remaining lic-owned tier-1 red** after fresh local benches. Dashboard ingest (stale) also flags `matmul_naive`, `num_gmres`, and three `li-math` ML rows.

Governing kernel: cache-blocked GEMM IKJ matching `matmul_blocked_core.c` oracle.

---

## Learned from (SOTA)

1. **BLIS / Goto & van de Geijn** — macro/micro-kernel blocking for L2/L3 residency; rank-1 updates with FMA.  
   - **Takeaway:** Li `ArrayMatMulBlocked2DF64` MIR path is correct structure; gap is codegen quality not algorithm.

2. **Eigen / OpenBLAS** — `gemm` uses packed panels + SIMD FMA on the `j` dimension.  
   - **Takeaway:** Manual `<4 x double>` loads on `j` match incumbent; scalar fallback uses `llvm.fmuladd`.

3. **LLVM loop vectorizer docs** — hand-vectorized rank-1 can beat autovec when trip counts are compile-time known.  
   - **Takeaway:** Explicit Li source loops (0.0157s) regress vs MIR hook (0.0110s); keep `mm_blocked_512` specialization.

4. **Org oracle** — `benchmarks/tier1_micro/matmul_blocked/common/matmul_blocked_core.c`  
   - **Takeaway:** Checksum `1288460.7563999966` locked; no tolerance relaxation.

---

## Quality table

| Axis | Before (dashboard CSV) | After (local `bench.py --runs 5`) | Verdict |
|------|------------------------|-----------------------------------|---------|
| **Accuracy** | checksum ok | verify ok (pure Li) | locked |
| **Speed `matmul_blocked`** | li=0.0158s cpp=0.0102s **1.549×** | li=0.0110s cpp=0.0085s **1.294×** | improved, still red |
| **Speed `matmul_naive`** | li=0.0036s cpp=0.0027s **1.333×** | li=0.0019s cpp=0.0018s **1.056×** | **green** (ingest pending) |
| **Speed `num_gmres`** | li=0.0007s cpp=0.0005s **1.400×** | li=0.0005s cpp=0.0005s **1.000×** | **green** (shared C kernel) |
| **Stability** | N/A tier-1 | N/A | locked |

---

## Commands

```bash
cd lic && ./scripts/build.sh
export LIC="$(pwd)/compiler/lic/lic"
python3 benchmarks/harness/bench.py --tier 1 --runs 5 --only matmul_blocked,matmul_naive,num_gmres
./scripts/check-tier1-li-vs-cpp.sh
# ingest (benchmarks repo):
cd ../benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

---

## Code changes

| Path | Change |
|------|--------|
| `compiler/codegen/emit.cpp` | `llvm.fmuladd` on `<4 x double>` blocked matmul inner store (was `fadd`+`fmul`) |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | Retained `mm_blocked_512` MIR hook (explicit Li loops regressed ~40%) |

---

## Next (human / follow-up)

- **PH-7e:** micro-kernel register blocking (4×k unroll hurt locally); consider `@vectorized` policy once G-par proof lands.
- **Ingest:** refresh org `latest.csv` — dashboard reds for `matmul_naive` / `num_gmres` are stale vs this machine.
- **li-math:** `ml_conv2d_forward`, `ml_mlp_*` reds are package `li-math`, not lic codegen.
- **Tier-2 yellow:** `md_thermostat_berendsen` (1.303×), `md_thermostat_nose_hoover` (1.291×) — shared-kernel review in `common/*_core.c`.
