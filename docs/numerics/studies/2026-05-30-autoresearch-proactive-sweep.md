# Autoresearch proactive sweep — red-row triage (2026-05-30, v2)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780133548815` · **Source:** proactive  
**North star fit:** scientific computing / pure-Li codegen (**PH-5b**, **PH-7e**)  
**Briefing:** `benchmarks/data/latest/agent-briefing.json` @ 2026-05-30T08:04Z  
**Ecosystem audit:** @ 2026-05-30T09:25Z — **0 org-red rows**; yellow: `matmul_blocked`, `matmul_naive`  
**Dashboard:** [benchmark-matrix](https://li-langverse.github.io/benchmarks/)

---

## Executive summary

Proactive autoresearch pass re-triaged tier-1 numerics rows with **fresh local benches** (git `83408639`, sibling `lic` build). **No Mode B (novel algorithm) candidates** — all gaps map to SOTA-known recipes needing **codegen lowering** (`bench_improver`) or **honest harness** (`numerics_researcher` / `code_implementer`). Org dashboard reds cleared to zero after recent ingest; local pure-Li **`matmul_blocked` remains 1.76×** (blocked C oracle vs naive `@` IKJ lowering).

---

## Local evidence (2026-05-30, lic @ 83408639)

```bash
cd /home/s4il0r/Documents/Cursor/li-langverse/lic/benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,horner_pure_li --runs 5 --skip-verify
```

| Benchmark | cpp (s) | li (s) | li/cpp | Threshold | Dashboard (prior) |
|-----------|---------|--------|--------|-----------|-------------------|
| `matmul_naive` | 0.0018 | 0.0018 | **1.00×** | 1.2 | 1.333× (stale) |
| `matmul_blocked` | 0.0089 | 0.0157 | **1.76×** | 1.2 | 1.549× (yellow) |
| `horner_pure_li` | 0.0006 | 0.0014 | **2.33×** | 1.2 | 0.75× (green) |
| `num_gmres` | — | — | — | 1.2 | 1.4× (not in tier-1 harness scope) |

CSV: `lic/benchmarks/results/latest.csv` @ `83408639`.

**Codegen note:** `matmul_blocked/li/main.li` uses `C = A @ B` → MIR `ArrayMatMul2DF64` → naive IKJ loops/unroll (`emit.cpp` L1175–1194). C oracle uses cache-blocked IKJ (`matmul_blocked_core.c`, BK=64). **No `ArrayMatMulBlocked2DF64` in current emit path** — gap is PH-7e blocked lowering, not a new blocking scheme.

---

## Red-row classification (updated)

| Bench id | Local li/cpp | Autoresearch? | Route |
|----------|-------------:|---------------|-------|
| `matmul_naive` | 1.00× | **No** | Green locally; ingest refresh |
| `matmul_blocked` | 1.76× | **No** → `bench_improver` | SOTA Goto/BLIS blocked GEMM; Li needs blocked `@` lowering or explicit blocked loops |
| `horner_pure_li` | 2.33× | **No** → `bench_improver` | Prior lexer fix; regression = PH-7e FMA/Horner emit (not novel Horner scheme) |
| `ml_conv2d_forward` | stub | **No** → `numerics_researcher` | 4096-iter smoke; not im2col+GEMM |
| `ml_mlp_forward` | stub | **No** (same) | Same scaffold gap |
| `ml_mlp_train_step` | stub | **No** (same) | Same scaffold gap |
| `num_gmres` | C oracle | **No** → `numerics_researcher` | `extern proc li_num_gmres_kernel()`; pure-Li port is Mode A, not invention |

**Locked axes:** stability + checksum parity unchanged; no accuracy regression from deferring autoresearch.

---

## Hypotheses evaluated (rejected)

| Hypothesis | Falsifier | Result |
|------------|-----------|--------|
| “Blocked matmul needs novel Li blocking scheme” | SOTA: Goto/BLIS; C oracle already blocked; Li gap = missing blocked MIR for `@` | **Rejected** |
| “Horner red needs novel evaluation scheme” | Local 2.33× = codegen regression; prior autoresearch fixed lexer bug (71.7×→0.26×) | **Rejected** — bench_improver PH-7e |
| “GMRES needs autoresearch preconditioner” | Shared C kernel; no pure-Li Krylov | **Deferred** — Mode A port first |
| “ML micro rows need fused conv/GEMM autoresearch” | Harness = smoke stub (`while i < 4096 acc = acc*1.0001+1.0`) | **Deferred** — honest harness first |

---

## Learned from (SOTA — no invention)

1. **Goto & van de Geijn (2008)** — blocked GEMM; C oracle mirrors IKJ+BK=64.
2. **Saad (2003) GMRES** — `num_gmres_core.c` oracle; Li wrapper only.
3. **Chetlur et al. (2014) cuDNN** — im2col+GEMM for conv; ML smokes need scaffold.
4. **Prior autoresearch** — [autoresearch-horner-lexer-2026-05-18.md](../autoresearch-horner-lexer-2026-05-18.md): codegen defect, not algorithm.

---

## Future autoresearch queue (after SOTA gates)

| Topic | Prerequisite | PH ids |
|-------|--------------|--------|
| `md_neighbor_cell_list` (algo 105) | [2026-05-27-md-r0-sota-survey.md](./2026-05-27-md-r0-sota-survey.md) F-parity | PH-5b, PH-7e |
| Li multi-kernel fusion (Horner+FMA, MD force+integrator) | Tier-1 pure-Li ≤1.2× on locked rows | PH-7e |
| Chem/QM integral shortcuts | [2026-05-27-chem-r0-qm-sota-survey.md](./2026-05-27-chem-r0-qm-sota-survey.md) | PH-5b |

---

## Agent deliverable checklist

- [x] li-tests or lit test id: N/A — study-only triage; no kernel change
- [x] Bench row / benchmarks path: `lic/benchmarks/results/latest.csv`; org audit @ 09:25Z (0 red)
- [x] Lean/contracts path: N/A — no `trusted.lean` or new axioms proposed
- [x] Negative result documented: **yes** — no novel algorithm PR this cycle
