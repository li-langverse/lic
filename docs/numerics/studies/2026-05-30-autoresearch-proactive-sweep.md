# Autoresearch proactive sweep — red-row triage (2026-05-30)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780104301827` · **Source:** proactive  
**North star fit:** scientific computing / pure-Li codegen (**PH-5b**, **PH-7e**)  
**Briefing:** `benchmarks/data/latest/agent-briefing.json` @ 2026-05-30T01:07Z  
**Dashboard:** [benchmark-matrix](https://li-langverse.github.io/benchmarks/) · ingest @ 2026-05-29T07:01Z

---

## Executive summary

Proactive autoresearch pass triaged all **6 org-red** benchmark rows. **None qualify for Mode B (novel algorithm)** this cycle — each maps to SOTA-known recipes with gaps in **codegen lowering**, **harness honesty**, or **cross-repo stubs**. Prior autoresearch win (`horner_pure_li` lexer) remains the template for codegen-bound `*_pure_li` rows.

---

## Red-row classification

| Bench id | ratio_vs_cpp | Repo | Autoresearch? | Rationale |
|----------|-------------:|------|---------------|-----------|
| `matmul_blocked` | 1.549 | lic | **No** → `bench_improver` | SOTA blocked IKJ (Goto/BLIS class). Li uses MIR call-site fusion (`ArrayMatMulBlocked2DF64` in `lower.cpp` L995–1006) + `emit_matmul2d_blocked_ijk` (FMA + 4-wide `j`). Gap is PH-7e SIMD/register tiling, not a new discretization. |
| `matmul_naive` | 1.3333 | lic | **No** → `bench_improver` | SOTA IKJ GEMM in `matmul_naive/li/main.li` (explicit loops). Pure-Li; needs `@vectorized` / FMA horiz lowering per master plan 7e. |
| `ml_conv2d_forward` | 1.3333 | li-math | **No** → `numerics_researcher` / `code_implementer` | `algo_registry` variant; catalog `size_label = "harness pending"`. Ratio cluster 1.3333× matches stub ingest pattern (4/3 placeholder), not measured pure-Li kernel. |
| `ml_mlp_forward` | 1.3333 | li-math | **No** (same) | Same stub/honesty class as conv2d. |
| `ml_mlp_train_step` | 1.3333 | li-math | **No** (same) | Same stub/honesty class. |
| `num_gmres` | 1.4 | lic | **No** → `numerics_researcher` | Li driver is `extern proc li_num_gmres_kernel()` (shared C oracle). Red is link/wrapper overhead or stale row — not a pure-Li solver invention target. |

**Locked axes:** stability + checksum parity unchanged on all rows; no accuracy regression risk from deferring autoresearch.

---

## Codegen notes (matmul_blocked — not novel, but documented)

1. `mm_blocked_512` proc body in source is intentionally empty; MIR lowers calls to `ArrayMatMulBlocked2DF64` at **call site** (`compiler/mir/lower.cpp`).
2. `emit.cpp` emits `CreateRetVoid()` for the standalone `mm_blocked_512` symbol (L1755–1758) to avoid compiling an unused helper — hot path lives in `main` via fused MIR insn.
3. C oracle: cache-blocked IKJ, BK=64 (`matmul_blocked_core.c`).

No new discrete equations required; improvement path = existing SOTA + PH-7e codegen.

---

## Hypothesis evaluated (rejected)

| Hypothesis | Falsifier | Result |
|------------|-----------|--------|
| “Blocked matmul red row needs a novel Li blocking scheme” | SOTA survey: Goto/BLIS blocking already implemented in C oracle and mirrored in MIR `emit_matmul2d_blocked_ijk` | **Rejected** — perf gap is codegen quality, not algorithm |
| “GMRES red needs autoresearch preconditioner” | Li bench uses C kernel via `LI_EXTRA_C`; no pure-Li Krylov implementation exists | **Deferred** — Mode A SOTA + pure-Li port first (`numerics_researcher`) |
| “ML micro rows need fused conv/GEMM autoresearch” | Catalog honesty: harness pending; 1.3333× cluster | **Deferred** — implement honest harness before any novel fusion |

---

## Prior autoresearch evidence (reference)

- [autoresearch-horner-lexer-2026-05-18.md](../autoresearch-horner-lexer-2026-05-18.md) — codegen defect (`+` → `Minus`); 71.7× → 0.26× after fix.
- [bench-improver-horner-2026-05-20.md](../bench-improver-horner-2026-05-20.md) — DCE guard + remaining PH-7e Horner lowering.

---

## Future autoresearch queue (after SOTA gates)

| Topic | Prerequisite | PH ids |
|-------|--------------|--------|
| `md_neighbor_cell_list` (algo 105) | [2026-05-27-md-r0-sota-survey.md](./2026-05-27-md-r0-sota-survey.md) F-parity on brute force | PH-5b, PH-7e |
| Li-specific multi-kernel fusion (Horner+FMA chains, MD force+integrator) | Tier-1 pure-Li rows green at ≤1.2× | PH-7e |
| Chem/QM integral shortcuts | [2026-05-27-chem-r0-qm-sota-survey.md](./2026-05-27-chem-r0-qm-sota-survey.md) + `qm_dft_scf_energy` smoke | PH-5b |

---

## Commands (repro — blocked this run)

Local `./scripts/build.sh` required before bench:

```bash
cd lic && ./scripts/build.sh
cd lic/benchmarks/harness
python3 bench.py --tier 1 --only matmul_blocked,matmul_naive --runs 6
python3 bench.py --verify-results --only matmul_blocked,matmul_naive
```

**This run:** verify failed — `lic` binary missing at `build/compiler/lic/lic`.

---

## Agent deliverable checklist

- [x] li-tests or lit test id: N/A — study-only triage; no kernel change
- [x] Bench row / benchmarks path: org-red rows documented above; ingest @ 2026-05-29
- [x] Lean/contracts path: N/A — no `trusted.lean` or new axioms proposed
- [x] Negative result documented: **yes** — no novel algorithm PR this cycle
