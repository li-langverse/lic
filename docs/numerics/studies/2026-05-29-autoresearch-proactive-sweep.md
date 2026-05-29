# Autoresearch proactive sweep — negative result (2026-05-29)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780083426193` · **Mode:** B triage (novelty gate)  
**North star:** PH-5b (proved numerics), PH-7e (pure-Li codegen)  
**Preflight:** `benchmarks/data/latest/agent-briefing.json` @ 2026-05-29T19:05Z · dashboard ingest @ 07:01Z (stale)

---

## Hypothesis

Six dashboard **red** tier-1 rows may require **novel** discretizations, solvers, or Li-specific algorithms beyond published SOTA.

## Falsification (per-row)

| Bench id | Dashboard ratio | Closest SOTA | Autoresearch verdict |
|----------|-----------------|--------------|----------------------|
| `matmul_blocked` | 1.549× | Goto/BLIS blocked GEMM | **Reject novel** — PH-7e LLVM fusion on existing `mm_blocked_512`; route to `bench_improver` |
| `matmul_naive` | 1.333× | BLAS IKJ + FMA | **Reject novel** — `@` → `ArrayMatMul2DF64`; local study ~1.05× on branch; [lic#418](https://github.com/li-langverse/lic/pull/418) |
| `ml_conv2d_forward` | 1.333× | im2col + GEMM | **Reject novel** — WP4 scalar smoke; needs real kernel scaffold |
| `ml_mlp_forward` | 1.333× | batched GEMM | **Reject novel** — same |
| `ml_mlp_train_step` | 1.333× | forward + backward GEMM | **Reject novel** — same |
| `num_gmres` | 1.4× | Saad GMRES (1986) | **Reject novel** — shared C oracle; Li wrapper only; prior local ~0.80× |

**Non-red signals reviewed:**

| Bench id | Status | Autoresearch verdict |
|----------|--------|----------------------|
| `horner_pure_li` | **Green** 0.75× | Prior negative (lexer); no new work |
| `md_thermostat_berendsen` | Yellow 1.30× | **Defer** — SOTA Berendsen sufficient; extern wrappers today |
| `md_thermostat_nose_hoover` | Yellow 1.29× | **Defer** — SOTA NHC sufficient |

## Learned from

1. **Goto & van de Geijn** — blocked GEMM is the standard recipe for `matmul_blocked`; Li gap is codegen, not algorithm.
2. **BLAS / LLVM `fmuladd`** — `@` lowering already implements IKJ+FMA; manual loops bypass PH-7e path.
3. **Saad (2003)** — GMRES is reference Krylov; bench uses fixed-size smoke oracle in `num_gmres_core.c`.
4. **MD SOTA survey (`md-r0`)** — neighbor cells (algo 105) are LAMMPS-class SOTA; invention deferred until implement parity fails.

## Quality table

| Axis | Before | After this pass |
|------|--------|-----------------|
| Speed | 6 stale dashboard reds | Triage only; no code change |
| Stability | tier-0 green | unchanged |
| Accuracy | oracle checksums | unchanged |
| Novelty | — | **No novel PR opened** |

## Commands

```bash
# After lic build:
cd lic/benchmarks/harness
python3 bench.py --tier 1 --only matmul_blocked,matmul_naive,num_gmres --runs 3

# Refresh dashboard:
cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh

# Evidence checklist (survey-only):
python3 scripts/numerics-evidence-checklist.py \
  --study docs/numerics/studies/2026-05-29-autoresearch-proactive-sweep.md
```

**Local repro blocked:** workspace lic binary not built (`./scripts/build.sh` required).

## Next owner

| Priority | Agent | Target |
|----------|-------|--------|
| P0 | `bench_improver` | Merge lic#418; `matmul_blocked` emit tuning |
| P0 | ingest | Clear stale reds after lic merge |
| P1 | `numerics_researcher` | `md_neighbor_cell_list` (algo 105) — Mode A implement |
| P2 | `autoresearch` | Re-open when backlog sets `novel: true` with SOTA insufficiency proof |

## Lean / contracts

N/A — no compiler or `trusted.lean` changes in this pass.
