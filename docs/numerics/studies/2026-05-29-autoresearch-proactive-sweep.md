# Autoresearch proactive sweep — 2026-05-29 (v5)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780094804882` · **Source:** proactive  
**North star:** PH-5b (proved numerics), PH-7e (math→SIMD)  
**Preflight:** `benchmarks/data/latest/agent-briefing.json` @ 2026-05-29T22:07Z · dashboard ingest @ 07:01Z (stale)

---

## Problem

Six tier-1 **red** rows on the org dashboard (`matmul_blocked`, `matmul_naive`, `ml_*`×3, `num_gmres`). Autoresearch mandate: invent novel numerics/codegen only when SOTA is insufficient. This pass triages each red for autoresearch eligibility vs `bench_improver` / implementation gaps.

---

## Hypotheses tested (negative results)

| Row | Hypothesis | Falsification | Verdict |
|-----|------------|---------------|---------|
| `matmul_blocked` (1.549× dash) | Li-specific blocked GEMM tiling beats Goto/BLIS | Local **1.25×** @ fc62e1d8; `mm_blocked_512` → `ArrayMatMulBlocked2DF64` MIR hook; SOTA blocked IKJ sufficient | **Reject novel tiling** — PH-7e emit tuning |
| `matmul_naive` (1.333× dash) | Novel IKJ loop order | Local **1.05×**; IKJ pure-Li matches C oracle | **Reject** — stale ingest; lic#418 merge + ingest |
| `num_gmres` (1.4× dash) | Novel Krylov variant | Local **1.25×**; Li uses shared C oracle (`LI_EXTRA_C`) | **Reject** — pure-Li GMRES is implementation, not invention |
| `ml_*` (1.333× each) | Novel conv/ML kernel | Harness = 4096-iter smoke stub, not real im2col/GEMM | **Reject** — scaffold SOTA first |
| `horner_pure_li` | Novel Horner scheme | Local **1.0×**; prior lexer fix (2026-05-18) | **Reject** (prior negative) |
| `md_thermostat_*` (yellow) | Adaptive Li-only thermostat | Berendsen/NHC SOTA; stubs share `md_core` oracle | **Defer** — post NVE matrix |

---

## Local evidence (2026-05-29, fc62e1d8)

```bash
cd lic && ./scripts/build.sh
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres,horner_pure_li --runs 5 --skip-verify
python3 bench.py --tier 1 --only matmul_blocked --runs 3 --verify-results
```

| Benchmark | cpp (s) | li (s) | li/cpp | Threshold | Dashboard |
|-----------|---------|--------|--------|-----------|-----------|
| `matmul_naive` | 0.0019 | 0.0020 | **1.05×** | 1.2 | 1.333× (stale) |
| `matmul_blocked` | 0.0091 | 0.0114 | **1.25×** | 1.2 | 1.549× (stale) |
| `num_gmres` | 0.0004 | 0.0005 | **1.25×** | 1.2 | 1.4× (stale) |
| `horner_pure_li` | 0.0005 | 0.0005 | **1.0×** | 1.2 | 0.75× (green) |

CSV: `lic/benchmarks/results/latest.csv`  
`matmul_blocked` verify: checksum **1288460.7563999966** (pure Li, parity ok).

---

## Learned from (SOTA — no invention needed)

1. **Goto & van de Geijn (2008)** — blocked GEMM micro-kernels; Li `ArrayMatMulBlocked2DF64` follows same IKJ+BK pattern.
2. **Saad (2003) GMRES** — `num_gmres_core.c` oracle; pure-Li port is standard Arnoldi + Givens.
3. **Chetlur et al. (2014) cuDNN** — im2col+GEMM for conv; `ml_*` smokes need this scaffold, not new math.
4. **Berendsen / Nose-Hoover** — MD thermostats (registry 108–109); SOTA sufficient until NVE drift matrix filled.

---

## Quality table

| Axis | Before (dashboard) | After (local) | Locked axis regression |
|------|-------------------|---------------|------------------------|
| Speed | 6 reds | 1 pure-Li red (`matmul_blocked` 1.25×) | None |
| Stability | tier-0 green | unchanged | None |
| Accuracy | verify ok on matmul_blocked | checksum parity confirmed | None |

**Improvement claim:** None — survey-only negative result. Value = routing reds to correct agent (`bench_improver` vs implementation).

---

## Commands (repro)

```bash
cd lic/benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 5 --verify-results
cd ../../.. && LIC_ROOT=. ./scripts/check-tier1-li-vs-cpp.sh  # optional strict
cd ../benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
```

---

## Contracts / Lean

N/A — no compiler proof or `trusted.lean` changes proposed.

---

## Next handoff

- **`bench_improver`:** `matmul_blocked` `ArrayMatMulBlocked2DF64` emit (FMA vec4, prefetch, OpenMP) — sole remaining pure-Li gap.
- **`numerics_researcher` / `code_implementer`:** `ml_*` real kernels; `num_gmres` pure-Li port; `md_neighbor_cell_list` (algo 105).
- **Ingest:** refresh dashboard after lic#418 merge.
