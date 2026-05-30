# Autoresearch proactive sweep R2 — red-row refresh (2026-05-30)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780148378835` · **Source:** proactive  
**North star fit:** scientific computing / pure-Li codegen (**PH-5b**, **PH-7e**)  
**Briefing:** `benchmarks/data/latest/agent-briefing.json` @ 2026-05-30T12:07Z (stale ingest)  
**Dashboard:** [benchmark-matrix](https://li-langverse.github.io/benchmarks/) · ingest @ 2026-05-29T07:01Z

---

## Executive summary

Second proactive autoresearch pass rebuilt `lic` on branch `main` lineage (HEAD `7e580bf9`, includes #543 matmul MIR fixes) and re-ran tier-1 benches. **No Mode B (novel algorithm) PR** — all actionable gaps remain SOTA codegen / harness honesty, not missing discretizations. Local evidence shows **4 of 6 briefing-red rows would flip green** after ingest; only `matmul_blocked` stays above 1.2×.

---

## Fresh local benchmarks (this host, 2026-05-30)

| Bench id | Li (s) | cpp (s) | ratio_vs_cpp | Briefing red? | Autoresearch? |
|----------|-------:|--------:|-------------:|:-------------:|:-------------:|
| `matmul_naive` | 0.0022 | 0.0019 | **1.158** | yes (1.333) | **No** → green locally; PH-7e lowering sufficient |
| `matmul_blocked` | 0.0118 | 0.0089 | **1.326** | yes (1.549) | **No** → init LUT + blocked emit gap (~13% vs #543 study) |
| `num_gmres` | 0.0005 | 0.0005 | **1.000** | yes (1.400) | **No** → shared C oracle; stale dashboard row |
| `ml_conv2d_forward` | — | — | 1.333 (ingest) | yes | **No** → `size_label = "harness pending"` stub cluster |
| `ml_mlp_forward` | — | — | 1.333 (ingest) | yes | **No** (same) |
| `ml_mlp_train_step` | — | — | 1.333 (ingest) | yes | **No** (same) |

Verify: `matmul_naive`, `matmul_blocked`, `num_gmres` checksum parity **ok** (pure Li / shared C).

Commands:

```bash
cd lic && ./scripts/build.sh
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_blocked,matmul_naive,num_gmres --runs 10
```

Post-merge ingest: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

---

## Hypotheses evaluated (all rejected for autoresearch)

| Hypothesis | Falsifier | Result |
|------------|-----------|--------|
| Novel Li cache-blocking scheme for `matmul_blocked` | Goto/BLIS IKJ already in C oracle + `emit_matmul2d_blocked_ijk`; gap shrank 1.549→1.326 after #543 without new math | **Rejected** |
| Fused Horner+FMA autoresearch kernel | `horner_pure_li` already green (~1× in prior studies); harness verify flake on first combined run (native spec path) — bench_improver hygiene | **Rejected** |
| ML micro fused conv/GEMM invention | Catalog honesty: harness pending; 1.3333× = placeholder ratio | **Deferred** |
| GMRES preconditioner invention | Driver uses `extern proc li_num_gmres_kernel()` (C); local 1.0× | **Rejected** |

---

## `matmul_blocked` remaining gap (bench_improver, not autoresearch)

1. **Init overhead:** Li uses 17+13 branch LUT procs (`mm_lut_a` / `mm_lut_b`) per matrix element; C oracle uses `(i+j)%17 * 0.01` inline — needs Phase **2i** int→float promotion, not a new blocking scheme.
2. **Hot path:** `mm_blocked_512` MIR → `ArrayMatMulBlocked2DF64` → `emit_matmul2d_blocked_ijk` (BK=64, FMA, vec4) — correct SOTA mirror; further wins = register tiling / `@vectorized`, PH-7e.

---

## Future autoresearch queue (unchanged)

| Topic | Prerequisite | PH ids |
|-------|--------------|--------|
| `md_neighbor_cell_list` | MD R0 SOTA survey + F-parity on brute force | PH-5b, PH-7e |
| Multi-kernel Li fusion (force+integrator) | Tier-1 pure-Li rows green at ≤1.2× | PH-7e |
| Chem/QM integral shortcuts | QM SOTA survey + `qm_dft_scf_energy` smoke | PH-5b |

---

## Agent deliverable checklist

- [x] li-tests or lit test id: N/A — study-only triage; no kernel change
- [x] Bench row / benchmarks path: local `benchmarks/results/latest.csv`; ingest refresh needed for dashboard
- [x] Lean/contracts path: N/A — no `trusted.lean` or new axioms proposed
- [x] Negative result documented: **yes** — no novel algorithm PR this cycle
