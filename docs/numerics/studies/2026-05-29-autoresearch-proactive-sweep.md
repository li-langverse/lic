# Autoresearch proactive sweep — tier-1 reds triage (2026-05-29)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780082345386` · **Source:** proactive  
**Mode:** Mode B survey → negative (no novel algorithm shipped)  
**north_star_fit:** PH-5b, PH-7e — pure-Li codegen; proof-before-perf  
**Preflight:** `benchmarks/data/latest/ecosystem-audit.json` @ 2026-05-29T19:20Z · [dashboard](https://li-langverse.github.io/benchmarks/)

---

## Problem

Org audit lists **6 red** tier-1 rows (`ratio_vs_cpp` > 1.2×). Autoresearch runs when SOTA is insufficient and a falsifiable novel method could beat cpp on locked axes (stability + accuracy default). This pass triages each red for **novel-algorithm** eligibility vs **bench_improver / numerics_researcher** routing.

---

## Learned from (SOTA sufficient)

1. **Goto & van de Geijn (2008)** — blocked GEMM (register/cache tiling); Li `mm_blocked_512` MIR hook matches standard i-k-j micro-kernel pattern.
2. **BLAS reference IKJ** — `matmul_naive` SOTA is fused FMA inner loop; Li `@` → `ArrayMatMul2DF64` is the correct recipe (see `2026-05-29-matmul-naive-at-codegen.md`).
3. **Saad GMRES** — Krylov subspace + Arnoldi; org oracle `num_gmres_core.c` is shared C; Li column uses `LI_EXTRA_C` extern — not a pure-Li algorithm gap.
4. **im2col + GEMM (Caffe/PyTorch)** — standard `ml_conv2d_forward` / MLP forward; WP4 smokes use scalar recurrence placeholder, not missing numerics invention.

---

## Red-row triage

| Benchmark | Dashboard ratio | Pure-Li? | SOTA sufficient? | Autoresearch verdict |
|-----------|-----------------|----------|------------------|----------------------|
| `matmul_blocked` | **1.549×** | Yes | Yes — blocked GEMM + PH-7e LLVM | **No novel algo** — codegen (`emit.cpp` FMA/SIMD on `mm_blocked_512`) |
| `matmul_naive` | **1.333×** | Yes | Yes — `@` operator | **No** — bench_improver fix (`C = A @ B`); local **~0.89×** cpp |
| `num_gmres` | **1.4×** | No (shared C) | Yes — textbook GMRES | **No** — local **1.0×** cpp; ingest stale |
| `ml_conv2d_forward` | **1.333×** | Smoke stub | Yes — im2col exists | **No** — implement SOTA kernel + oracle, not invent |
| `ml_mlp_forward` | **1.333×** | Smoke stub | Yes | **No** — same |
| `ml_mlp_train_step` | **1.333×** | Smoke stub | Yes | **No** — same |

**Hypothesis H1 (novel blocked GEMM tiling beats cpp):** **Rejected** — local blocked matmul **1.33×** with checksum PASS; gap is LLVM lowering width/prefetch, not algorithm class.

**Hypothesis H2 (novel Horner / recurrence for ml smokes):** **Rejected** — smokes are catalog honesty placeholders (`4096`-step scalar loop), not physics/ML workloads.

---

## Local harness (2026-05-29, this host, `bench.py --runs 1`)

| Benchmark | cpp (s) | li (s) | Ratio | Verify |
|-----------|---------|--------|-------|--------|
| `matmul_blocked` | 0.0083 | 0.0110 | **1.33×** | PASS |
| `matmul_naive` | 0.0019 | 0.0017 | **0.89×** | PASS |
| `num_gmres` | 0.0005 | 0.0004 | **0.80×** | PASS |
| `horner_pure_li` | — | — | — | **FAIL** (native vs spec `inf`) |

`ml_*` rows: not in lic `bench.py` tier-1 scope (`bench: no benchmarks in scope`).

---

## Vertical backlogs (novel flag)

| Vertical | Next todo | `novel: true`? | Route |
|----------|-----------|---------------|-------|
| MD (`sim-md-research-backlog`) | `md-r2-neighbor-list-gap` | No | `numerics_researcher` — LAMMPS cell list is SOTA |
| Chem (`sim-chem-research-backlog`) | `chem-r2-dft-scf-gap` | No | `numerics_researcher` — Gaussian/ORCA recipes suffice |

Autoresearch deferred until a todo explicitly sets `novel: true` **and** SOTA survey documents insufficiency.

---

## Quality table (this pass)

| Axis | Before | After autoresearch | Verdict |
|------|--------|-------------------|---------|
| Speed | 6 dashboard reds | No code shipped | **No improvement** (by design — survey only) |
| Accuracy | matmul checksums OK | unchanged | locked |
| Stability | tier-0 unchanged | unchanged | locked |

---

## Commands

```bash
cd lic/benchmarks/harness
python3 bench.py --tier 1 --only matmul_blocked --runs 3
python3 bench.py --tier 1 --only matmul_naive --runs 3
python3 bench.py --tier 1 --only num_gmres --runs 3
python3 bench.py --tier 1 --only horner_pure_li --runs 1 --verify-results
cd ../../benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
python3 scripts/numerics-evidence-checklist.py \
  --study docs/numerics/studies/2026-05-29-autoresearch-proactive-sweep.md
```

---

## Status

**Closed — negative autoresearch (proactive sweep).** All tier-1 reds route to **bench_improver** (codegen), **ingest**, or **SOTA kernel scaffold** — not novel discretizations.
