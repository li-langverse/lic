# Autoresearch proactive sweep — tier-1 red triage (2026-05-29)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780089636246` · **Mode:** survey + local benches (negative novel-algorithm result)  
**North star:** PH-5b, PH-7e — proof-before-perf; novel methods only when SOTA insufficient  
**Preflight:** `benchmarks/data/latest/ecosystem-audit.json` @ 2026-05-29T07:01Z (stale ingest) · [dashboard](https://li-langverse.github.io/benchmarks/)

---

## Problem

Org briefing lists **6 red** tier-1 rows (`matmul_blocked`, `matmul_naive`, `ml_conv2d_forward`, `ml_mlp_forward`, `ml_mlp_train_step`, `num_gmres`). Autoresearch must decide whether any row warrants a **novel algorithm** (new discretization, Krylov variant, ML kernel) vs delegating to **bench_improver** / **numerics_researcher** SOTA codegen.

---

## Hypotheses tested (falsifiable)

| ID | Hypothesis | Falsifier | Result |
|----|------------|-----------|--------|
| H1 | New blocked-GEMM tiling beats Goto/BLIS on Li pure path | `matmul_blocked` li/cpp ≤ 1.2× after PH-7e emit only | **Rejected** — 1.25× local; gap is LLVM fusion not tile math |
| H2 | Modified Arnoldi / left-precond GMRES beats Saad GMRES at N=48 | li/cpp > 1.2× with shared oracle | **Rejected** — 0.83× local; row is ingest artifact |
| H3 | Novel Horner scheme needed for `horner_pure_li` | verify fail or li/cpp > 1.2× | **Rejected** — 1.0× local; prior lexer fix sufficient |
| H4 | im2col-free conv wins on smoke MLP rows | no C oracle + no pure-Li kernel | **Deferred** — WP4 registry smokes; SOTA = im2col+GEMM |

---

## Local performance (2026-05-29, fc62e1d8, `-O3 -march=native`)

Repro:

```bash
cd lic && ./scripts/build.sh
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres,horner_pure_li --runs 5 --skip-verify
```

| Bench id | cpp (s) | li (s) | li/cpp | Dashboard | pure_li? |
|----------|---------|--------|--------|-----------|----------|
| `matmul_naive` | 0.0018 | 0.0019 | **1.06×** | 1.33× red | yes |
| `matmul_blocked` | 0.0087 | 0.0109 | **1.25×** | 1.55× red | yes |
| `num_gmres` | 0.0006 | 0.0005 | **0.83×** | 1.40× red | no (shared C) |
| `horner_pure_li` | 0.0005 | 0.0005 | **1.00×** | 0.75× green | yes |

Raw CSV: `lic/benchmarks/results/latest.csv` (gitignored; attach to PR body on ingest).

---

## SOTA survey (Mode A — no novel PR)

### Learned from

1. **Goto & van de Geijn (2008)** — cache-blocked GEMM; Li `mm_blocked_512` MIR hook follows IKJ micro-kernel pattern.  
2. **BLIS / OpenBLAS** — rank-k update + packing; Li blocked path uses BK=64 tiles via `ArrayMatMulBlocked2DF64`.  
3. **Saad (2003) GMRES** — restarted Arnoldi; `num_gmres_core.c` is canonical oracle; Li driver is thin FFI.  
4. **Chetlur et al. (2014) cuDNN** — im2col + GEMM for conv; ML registry smokes alias matmul until real kernels land.

### Quality table (locked axes: stability + accuracy)

| Target | Stability | Accuracy | Speed claim | Autoresearch verdict |
|--------|-----------|----------|-------------|---------------------|
| `matmul_blocked` | N/A (micro) | checksum parity | 1.25× local | **bench_improver** — emit FMA vec4, prefetch |
| `matmul_naive` | N/A | checksum parity | 1.06× local | **bench_improver** — ingest clears stale red |
| `num_gmres` | N/A | shared C oracle | 0.83× local | **ingest** — not pure_li |
| `ml_*` | pending scaffold | pending | 1.33× dash | **numerics_researcher** — scaffold + SOTA im2col |
| `horner_pure_li` | N/A | verify drift open | 1.0× local | **bench_improver** — lic#388 verify fix |

---

## Novelty vs SOTA (negative result)

No algorithm note opened. Closest published methods already implemented; remaining gaps are **codegen lowering** (PH-7e) and **harness honesty** (pure-Li GMRES, ML scaffolds).

---

## Commands checklist

```bash
# Evidence checklist (survey-only — no --novel)
python3 scripts/numerics-evidence-checklist.py \
  --study docs/numerics/studies/2026-05-29-autoresearch-proactive-sweep.md
```

Lean/contracts: **N/A** — no compiler proof or `trusted.lean` changes this pass.

---

## Handoffs

| Next agent | Work item |
|------------|-----------|
| `bench_improver` | `matmul_blocked` emit — target ≤1.2× (lic#407, #437 stack) |
| `bench_improver` | Merge lic#420/#437 + ingest → clear stale `matmul_naive` red |
| `numerics_researcher` | Pure-Li GMRES port (`num_gmres` currently `LI_EXTRA_C`) |
| `numerics_researcher` | ML conv/MLP real kernels in li-math |
| `numerics_researcher` | `md_neighbor_cell_list` (post md-r0 survey) |
