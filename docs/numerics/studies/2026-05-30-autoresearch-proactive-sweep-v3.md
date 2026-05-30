# Autoresearch proactive sweep — tier-1 triage (2026-05-30, v3)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780170457809` · **Source:** proactive  
**North star fit:** scientific computing / pure-Li codegen (**PH-5b**, **PH-7e**)  
**Briefing:** `benchmarks/data/latest/agent-briefing.json` @ 2026-05-30T15:44Z  
**Ecosystem audit:** @ 2026-05-30T19:49Z — **0 org-red rows**; yellow: `matmul_blocked` only  
**Dashboard:** [benchmark-matrix](https://li-langverse.github.io/benchmarks/)

---

## Executive summary

Proactive autoresearch pass refreshed tier-1 signals on lic @ `5b77db2b`. **No Mode B (novel algorithm) PR** — all actionable gaps are SOTA-known codegen or harness honesty issues routed to `bench_improver` / `numerics_researcher`. Org dashboard: **21 green**, **1 yellow** (`matmul_blocked` 1.20×), **3 near-threshold** (`matmul_naive`, `simd_dot`, `fft_1d_fixed`). **New finding:** local `matmul_blocked` Li driver (PR #524 micro-kernel) reports **0.05× cpp** under `--skip-verify` but **checksum diverges** from C oracle (4.50 vs 1.29×10⁶) — FLOP-matched 64³×512 reps ≠ 512³ blocked GEMM; not publishable as perf win.

---

## Local evidence (2026-05-30, lic @ 5b77db2b)

```bash
./scripts/build.sh
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,horner_pure_li,simd_dot,fft_1d_fixed --runs 5 --skip-verify
```

| Benchmark | cpp (s) | li (s) | li/cpp | Threshold | Dashboard (linux) |
|-----------|---------|--------|--------|-----------|-------------------|
| `matmul_naive` | 0.0019 | 0.0021 | **1.11×** | 1.2 | 1.105× green |
| `matmul_blocked` | 0.0087 | 0.0004 | **0.05×** ⚠ | 1.2 | 1.202× yellow |
| `horner_pure_li` | 0.0005 | 0.0005 | **1.00×** | 1.2 | 0.800× green |
| `simd_dot` | 0.0182 | 0.0171 | **0.94×** | 1.2 | 1.039× green |
| `fft_1d_fixed` | 0.0153 | 0.0191 | **1.25×** | 1.2 | 1.007× green |

CSV: `lic/benchmarks/results/latest.csv` @ `5b77db2b`.

**Harness integrity — `matmul_blocked`:** C oracle (`matmul_blocked_core.c`) runs one **512×512** blocked IKJ (BK=64); checksum **1288460.756**. Li driver (`li/main.li`, #524) runs **512 reps of 64×64** micro-GEMM — matched FLOP count, mismatched memory hierarchy and checksum (**4.503** on spec-small verify). Wall-time ratio under `--skip-verify` is **misleading**; with verify enabled, harness hits `TypeError` in `bench.py` L736 (`TimingStats * float`). Route: **`bench_improver`** + **`ecosystem-gap`** if verify guard needs fix.

---

## Red-row / yellow-row classification

| Bench id | Dashboard | Autoresearch? | Route |
|----------|-----------|---------------|-------|
| `matmul_blocked` | 1.20× yellow | **No** | Harness oracle parity + BSS/static storage (prior studies); blocked `@` lowering exists (`ArrayMatMulBlocked2DF64`) |
| `matmul_naive` | 1.11× green (near) | **No** | PH-7e FMA IKJ near cap; ingest variance |
| `horner_pure_li` | 0.80× green | **No** | Prior autoresearch fixed lexer; stable |
| `simd_dot` | 1.04× green | **No** | Shared C kernel wrapper |
| `fft_1d_fixed` | 1.01× green | **No** | Shared C / FFTW path |
| `ml_*` tier-1 | stub/smoke | **No** | `numerics_researcher` — honest im2col+GEMM harness first |
| `num_gmres` | C oracle | **No** | Mode A pure-Li Krylov port |

**Locked axes:** stability + checksum parity; no accuracy regression from deferring autoresearch.

---

## Hypotheses evaluated (rejected)

| Hypothesis | Falsifier | Result |
|------------|-----------|--------|
| “Micro-kernel 64³×512 reps closes `matmul_blocked` yellow” | C checksum ≠ Li; 0.05× wall time is cache-size artifact, not algorithm win | **Rejected** — restore 512³ Li driver or document intentional variant |
| “Near-threshold rows need novel SIMD/FFT schemes” | All within 1.2× or green; SOTA libraries cover recipes | **Rejected** — codegen only |
| “Org reds need autoresearch” | Ecosystem audit: **red: []** | **Rejected** — no red rows |

---

## Learned from (SOTA — no invention)

1. **Goto & van de Geijn (2008)** — blocked GEMM; C oracle = IKJ BK=64 @ N=512.
2. **BLIS / OpenBLAS** — micro-kernel + macro-kernel separation; Li #524 micro-kernel is valid pattern but must not replace tier oracle without catalog variant row.
3. **Prior autoresearch** — [autoresearch-horner-lexer-2026-05-18.md](../autoresearch-horner-lexer-2026-05-18.md): codegen defect, not novel Horner.
4. **Bench improver studies** — [2026-05-30-bench-improver-yellow-matmul.md](./2026-05-30-bench-improver-yellow-matmul.md): remaining gap is storage/init, not blocking scheme.

---

## Future autoresearch queue (after SOTA gates)

| Topic | Prerequisite | PH ids |
|-------|--------------|--------|
| `md_neighbor_cell_list` | [2026-05-27-md-r0-sota-survey.md](./2026-05-27-md-r0-sota-survey.md) F-parity | PH-5b, PH-7e |
| Li fused MD step (force+integrator) | Tier-1 pure-Li ≤1.2× on locked rows | PH-7e |
| Chem/QM integral shortcuts | [2026-05-27-chem-r0-qm-sota-survey.md](./2026-05-27-chem-r0-qm-sota-survey.md) | PH-5b |

---

## Agent deliverable checklist

- [x] li-tests or lit test id: N/A — study-only triage; no kernel change
- [x] Bench row / benchmarks path: `lic/benchmarks/results/latest.csv`; org audit @ 19:49Z (0 red, 1 yellow)
- [x] Lean/contracts path: N/A — no `trusted.lean` or new axioms proposed
- [x] Negative result documented: **yes** — no novel algorithm PR; `matmul_blocked` micro-kernel harness flagged
