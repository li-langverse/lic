# Autoresearch proactive sweep — 2026-05-30 (v3)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780177654969` · **Source:** proactive  
**North star fit:** scientific computing / pure-Li codegen (**PH-5b**, **PH-7e**)  
**Briefing:** `benchmarks/data/latest/agent-briefing.json` @ 2026-05-30T21:46Z  
**Ecosystem audit:** @ 2026-05-30T21:45Z — **0 org-red rows**; yellow: `matmul_blocked` (1.202×)  
**Dashboard:** [benchmark-matrix](https://li-langverse.github.io/benchmarks/)

---

## Executive summary

Proactive autoresearch pass refreshed tier-1 signals and ran local `bench.py` on agent workspace git `3710a3c7`. **No Mode B (novel algorithm) candidates** — remaining gaps are SOTA-known codegen (`bench_improver` / PH-7e) or harness honesty (`ecosystem-gap`). **Critical:** agent-branch `matmul_blocked/li/main.li` uses **64×64×512-rep micro-GEMM** while the C oracle is **512×512 blocked IKJ** — local Li/cpp ratios (~0.05×) are **invalid** for perf claims until drivers match sibling `lic` (`mm_blocked_512` MIR).

---

## Dashboard signals (ingest @ 2026-05-30T15:32Z)

| Benchmark | Li/cpp | Status | Threshold |
|-----------|--------|--------|-----------|
| `matmul_blocked` | **1.202×** | yellow | 1.2 |
| `matmul_naive` | 1.105× | green (near) | 1.2 |
| `simd_dot` | 1.039× | green (near) | 1.2 |
| `fft_1d_fixed` | 1.007× | green (near) | 1.2 |
| `horner_pure_li` | 0.80× | green | 1.2 |

Source: `benchmarks/data/latest/ecosystem-audit.json`, `summary.json`.

---

## Local evidence (2026-05-30, workspace @ 3710a3c7)

```bash
# sibling lic compiler symlinked into workspace build/
cd lic/benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,horner_pure_li,simd_dot,fft_1d_fixed --runs 5 --skip-verify
```

| Benchmark | cpp (s) | li (s) | li/cpp | Dashboard | Valid? |
|-----------|---------|--------|--------|-----------|--------|
| `matmul_naive` | 0.0018 | 0.0004 | 0.22× | 1.105× | MIR hook OK; timing variance |
| `matmul_blocked` | 0.0086 | 0.0004 | **0.05×** | 1.202× | **Invalid** — wrong problem shape |
| `horner_pure_li` | 0.0005 | 0.0014 | 2.80× | 0.80× | Build variance; not novel |
| `simd_dot` | 0.0186 | 0.0180 | 0.97× | 1.039× | OK |
| `fft_1d_fixed` | 0.0152 | 0.0153 | 1.01× | 1.007× | OK |

CSV: `lic/benchmarks/results/latest.csv` @ `3710a3c7`.

**Harness drift:** workspace driver `matmul_blocked/li/main.li` calls explicit `mm_blocked_64` in a 512× rep loop (64³ tiles). Sibling `lic` on `dev` uses `mm_blocked_512(C,A,B)` MIR → `ArrayMatMulBlocked2DF64` on full 512² workspace (C oracle parity). Autoresearch **must not** interpret sub-0.5× matmul ratios on this branch.

**Verify guard error:** `bench.py --verify` aborts with `TypeError: TimingStats * float` at line 736 — DCE/size guard not usable until `bench_improver` lands `TimingStats.mean` fix.

---

## Red-row / yellow-row classification

| Bench id | Autoresearch? | Route |
|----------|---------------|-------|
| `matmul_blocked` (1.202× dash) | **No** | PH-7e blocked IKJ emit tuning (`bench_improver`) |
| `matmul_naive` (1.105×) | **No** | Mode A — near green; MIR FMA squeeze |
| `horner_pure_li` (0.80× dash) | **No** — closed | Prior negative autoresearch; reopen only on regression |
| `simd_dot`, `fft_1d_fixed` | **No** | Mode A codegen / vendor parity |
| `ml_*` stubs | **No** | `numerics_researcher` — honest harness first |
| `num_gmres` | **No** | Mode A pure-Li Krylov port |

---

## Hypotheses evaluated (rejected)

| Hypothesis | Falsifier | Result |
|------------|-----------|--------|
| Novel Li blocking beyond Goto/BLIS | C oracle already BK=64 IKJ; gap is MIR→LLVM | **Rejected** |
| Rep-tiled 64³ micro-GEMM as novel win | Flop-matched but **not oracle-shaped**; invalid bench | **Rejected** + harness fix |
| Horner needs new evaluation scheme | Dashboard green; local 2.8× = PH-7e FMA emit | **Rejected** |
| Fused MD force+integrator | SOTA survey complete; stubs share `md_core` | **Deferred** |

---

## Learned from (SOTA — no invention)

1. **Goto & van de Geijn (2008)** — blocked GEMM; C oracle mirrors IKJ+BK=64.
2. **BLIS micro-kernel pattern** — Li `ArrayMatMulBlocked2DF64` follows same recipe.
3. **Prior autoresearch** — Horner lexer fix was codegen defect, not algorithm ([autoresearch-horner-lexer-2026-05-18.md](../autoresearch-horner-lexer-2026-05-18.md)).
4. **Bench improver @ 57f114cb** — static 512² workspace restored on `dev`; agent workspace drifted.

---

## Future autoresearch queue (after SOTA + harness gates)

| Topic | Prerequisite | PH ids |
|-------|--------------|--------|
| `md_neighbor_cell_list` | [2026-05-27-md-r0-sota-survey.md](./2026-05-27-md-r0-sota-survey.md) F-parity | PH-5b, PH-7e |
| Li multi-kernel fusion (Horner+FMA, MD force+integrator) | Tier-1 pure-Li ≤1.2× on locked rows + oracle parity | PH-7e |
| Chem/QM integral shortcuts | [2026-05-27-chem-r0-qm-sota-survey.md](./2026-05-27-chem-r0-qm-sota-survey.md) | PH-5b |

---

## Agent deliverable checklist

- [x] li-tests or lit test id: N/A — study-only triage; no kernel change
- [x] Bench row / benchmarks path: `data/latest/ecosystem-audit.json`; local `benchmarks/results/latest.csv` @ `3710a3c7` (matmul_blocked invalid)
- [x] Lean/contracts path: N/A — no `trusted.lean` or new axioms proposed
- [x] Negative result documented: **yes** — no novel algorithm PR; harness drift flagged
