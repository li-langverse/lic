# Autoresearch proactive sweep — tier-1 red triage (2026-05-29)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780084678496` · **Mode:** B (novel-method triage; negative results)  
**North star:** PH-5b (proved numerics), PH-7e (math→SIMD lowering)  
**Preflight:** `benchmarks/data/latest/ecosystem-audit.json` @ 2026-05-29T19:05Z · dashboard ingest @ 07:01Z (stale)

---

## Problem

Org briefing lists **6 red** tier-1 rows (`matmul_blocked`, `matmul_naive`, `ml_*`×3, `num_gmres`). Autoresearch runs only when SOTA is insufficient and a falsifiable metric can prove a novel method wins. This pass triages each red for **novel-algorithm** eligibility vs **bench_improver / ingest** routing.

---

## Hypotheses tested (all rejected)

| Bench id | Hypothesis | Closest SOTA | Verdict |
|----------|------------|--------------|---------|
| `matmul_blocked` | New cache-blocking / micro-kernel tiling beats Goto/BLIS pattern | BLIS/Goto blocked GEMM (BK=64, IKJ) | **Reject** — gap is LLVM fusion on `mm_blocked_512`, not tiling math |
| `matmul_naive` | Novel IKJ reorder or register blocking | Classical IKJ GEMM + `@` lowering | **Reject** — local 1.06× cpp; lic#418 `@` path pending merge |
| `num_gmres` | Novel Krylov basis / restart scheme | Saad GMRES(m) + Arnoldi | **Reject** — shared C oracle; local 1.0× cpp |
| `ml_conv2d_forward` | Novel conv algorithm | im2col + GEMM / Winograd (deferred) | **Reject** — WP4 smoke scaffold; no real kernel yet |
| `ml_mlp_forward` | Novel MLP layout | batched GEMM + ReLU | **Reject** — same scaffold gap |
| `ml_mlp_train_step` | Novel autodiff scheme | reverse-mode + GEMM | **Reject** — same scaffold gap |
| `horner_pure_li` | New Horner recurrence | Horner FMA chain | **Reject** (prior) — lexer fix retained; verify oracle drift on main |

No discrete equation or stability claim was invented; all rows map to published recipes already in harness oracles.

---

## Local evidence (2026-05-29, fc62e1d8, `-O3 -march=native`)

Commands:

```bash
cd lic && ./scripts/build.sh
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres --runs 5 --skip-verify
```

| Bench | cpp (s) | li (s) | li/cpp | Catalog threshold | Dashboard (stale) |
|-------|---------|--------|--------|-------------------|-------------------|
| `matmul_naive` | 0.0018 | 0.0019 | **1.06×** | ≤1.2× | 1.33× red |
| `matmul_blocked` | 0.0086 | 0.0108 | **1.26×** | ≤1.2× | 1.55× red |
| `num_gmres` | 0.0005 | 0.0005 | **1.0×** | ≤1.2× | 1.4× red |

CSV: `lic/benchmarks/results/latest.csv`. Dashboard reds for `matmul_naive` and `num_gmres` are **ingest staleness**, not novel-method gaps.

`horner_pure_li` verify **FAIL** on this tree (`native != spec 'inf'`) — validity before further PH-7e claims; not a novel-algorithm target.

---

## Quality table (autoresearch axes)

| Axis | Before (dashboard) | After (local) | Locked? |
|------|-------------------|---------------|---------|
| Speed `matmul_naive` | red 1.33× | green 1.06× | advisory |
| Speed `matmul_blocked` | red 1.55× | red 1.26× (~5% over) | advisory |
| Speed `num_gmres` | red 1.4× | green 1.0× | advisory |
| Stability | tier-0 N/A for micro | unchanged | locked |
| Accuracy | verify ok matmul_* | verify ok matmul_* | locked |

---

## Learned from

1. **BLIS / Goto & van de Geijn** — cache-blocked GEMM micro-kernels; Li `matmul_blocked` already mirrors BK=64 IKJ in C oracle.  
2. **Saad GMRES** — restarted Arnoldi; Li uses shared C core — perf is driver overhead, not Krylov novelty.  
3. **Prior autoresearch (2026-05-18)** — `horner_pure_li` red was lexer `+`/`−` bug, not Horner math (`docs/numerics/autoresearch-horner-lexer-2026-05-18.md`).

---

## Recommended routing (not autoresearch)

| Action | Owner | Notes |
|--------|-------|-------|
| Merge lic#418 (`matmul_naive` `@` path) + ingest | bench_improver | Clears stale dashboard red |
| PH-7e emit: FMA vec4, prefetch, OpenMP on `mm_blocked_512` | bench_improver | ~5–10% to ≤1.2× locally |
| Re-ingest tier-1 | benchmarks | `LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh` |
| Scaffold `ml_*` + C oracle | numerics_researcher | im2col/GEMM SOTA |
| Fix `horner_pure_li` verify oracle | bench_improver | validity gate |

---

## Contracts / Lean

N/A — survey-only; no `trusted.lean` or new axioms. PH-7e matmul lowering remains advisory until G-math loop specs land.

---

## Repro checklist

- [x] `bench.py` tier-1 rows measured locally
- [x] Negative result documented (this file)
- [ ] Ingest refresh (blocked on merge + human ingest)
- [ ] `numerics-evidence-checklist.py --novel` — N/A (no novel algorithm note)
