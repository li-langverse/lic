# Autoresearch proactive sweep — 2026-05-30 (v2)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780140585818` · **Source:** proactive  
**North star fit:** scientific computing / pure-Li codegen (**PH-5b**, **PH-7e**)  
**Briefing:** `benchmarks/data/latest/agent-briefing.json` @ 2026-05-30T10:59Z  
**Ecosystem audit:** `benchmarks/data/latest/ecosystem-audit.json` @ 2026-05-30T11:33Z (ingest @ 2026-05-29T18:47Z)  
**Dashboard:** [benchmark-matrix](https://li-langverse.github.io/benchmarks/)

---

## Executive summary

Proactive pass refreshed **6 org-red** tier-1 rows and **5 near-threshold** physics rows. **No Mode B (novel algorithm) PR** — reds map to PH-7e codegen (`matmul_blocked`, `horner_pure_li`), harness honesty (`ml_*`), or shared-C oracle (`num_gmres`). Fresh local benches on `lic@a094d179` show `matmul_naive` **green (1.0×)** but `matmul_blocked` **regressed to 1.72×** vs prior 1.25×; `horner_pure_li` **2.33×** with verify checksum **`inf`** (`x=1.1` overflow) — **bench_improver** + finite-`x` fix, not autoresearch.

---

## Red-row classification

| Bench id | Dashboard ratio | Local li/cpp (2026-05-30) | Autoresearch? | Route |
|----------|----------------:|--------------------------:|---------------|-------|
| `matmul_blocked` | 1.549 | **1.72** (0.0155/0.0090 s) | **No** | `bench_improver` — Goto/BLIS-class IKJ+BK already in MIR (`ArrayMatMulBlocked2DF64`) |
| `matmul_naive` | 1.333 | **1.0** (0.0019/0.0019 s) | **No** | Ingest refresh; local green |
| `ml_conv2d_forward` | 1.333 | (not run) | **No** | `code_implementer` — catalog `harness pending` |
| `ml_mlp_forward` | 1.333 | (not run) | **No** | same stub cluster |
| `ml_mlp_train_step` | 1.333 | (not run) | **No** | same stub cluster |
| `num_gmres` | 1.4 | (not run) | **No** | `numerics_researcher` — shared C oracle (`LI_EXTRA_C`) |

**Near-threshold (dashboard):** `num_cholesky` 1.17×, `cloth_swing` 1.15×, `robo_*` 1.11× — physics-tier; Mode A SOTA sufficient.

**Compact briefing note:** preflight compact snapshot listed `red: []` / 22 green (subset view); full matrix retains **6 reds** — treat dashboard ingest as stale until `ingest-lic.sh` refresh.

---

## Local evidence (2026-05-30, `lic` built, commit `a094d179`)

```bash
cd lic/benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,horner_pure_li,simd_dot --runs 3 --skip-verify
python3 bench.py --tier 1 --only matmul_blocked,horner_pure_li --runs 3 --verify-results
```

| Benchmark | cpp (s) | li (s) | li/cpp | Threshold | Verify |
|-----------|---------|--------|--------|-----------|--------|
| `matmul_naive` | 0.0019 | 0.0019 | **1.0×** | 1.2 | — |
| `matmul_blocked` | 0.0090 | 0.0155 | **1.72×** | 1.2 | checksum **1288460.7564** OK |
| `horner_pure_li` | 0.0006 | 0.0014 | **2.33×** | 1.2 | result **`inf`** (x=1.1 overflow) |
| `simd_dot` | 0.0175 | 0.0184 | **1.05×** | 1.2 | shared C kernel |

CSV: `lic/benchmarks/results/latest.csv`

---

## Hypotheses evaluated (negative)

| Hypothesis | Falsifier | Result |
|------------|-----------|--------|
| Novel blocked-GEMM tiling for `matmul_blocked` | SOTA IKJ+BK in C oracle + MIR fusion; checksum parity holds | **Rejected** — emit/register tiling only |
| Novel Horner recurrence for `horner_pure_li` | Prior lexer autoresearch win; current gap is perf + finite verify (`x` must be &lt;1) | **Rejected** — PH-7e FMA/unroll (`bench_improver`) |
| Novel ML fused kernels for `ml_*` reds | 1.333× stub cluster; harness not measuring real im2col/GEMM | **Rejected** — implement honest harness first |
| Novel Krylov for `num_gmres` | No pure-Li GMRES; C kernel via extras | **Deferred** — Mode A port |

---

## Future autoresearch queue (after SOTA gates)

| Topic | Prerequisite | PH ids |
|-------|--------------|--------|
| `md_neighbor_cell_list` (algo 105) | [2026-05-27-md-r0-sota-survey.md](./2026-05-27-md-r0-sota-survey.md); `md-r2-neighbor-list-gap` handoff | PH-5b, PH-7e |
| Li MD force+integrator fusion | NVE stability matrix + neighbor list green | PH-7e |
| QM integral shortcuts | [2026-05-27-chem-r0-qm-sota-survey.md](./2026-05-27-chem-r0-qm-sota-survey.md); `qm_dft_scf_energy` validity | PH-5b |

No `novel: true` items in `sim-md-research-backlog.md` / `sim-chem-research-backlog.md` this cycle.

---

## Agent deliverable checklist

- [x] li-tests or lit test id: N/A — study-only triage
- [x] Bench row / benchmarks path: 6 reds + local CSV above; `benchmarks/catalog.toml` thresholds unchanged
- [x] Lean/contracts path: N/A — no `trusted.lean` or new axioms
- [x] Negative result documented: **yes** — no novel algorithm PR
