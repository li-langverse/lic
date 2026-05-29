# Autoresearch proactive sweep (2026-05-29)

**Run:** `autoresearch-1780050687615` · **Branch:** `chore/agent-bench_improver-50434717`  
**North star:** PH-7e (math→SIMD / pure-Li codegen), PH-5b (proved numerics) · **Mode:** briefing refresh + harness unblock (no novel algorithm PR)

**Preflight:** `benchmarks/data/latest/ecosystem-audit.json` @ 2026-05-29T07:25Z · [dashboard](https://li-langverse.github.io/benchmarks/)

---

## Executive signals (briefing refresh)

| Signal | Value |
|--------|--------|
| Catalog **red** | **0** rows |
| Catalog **yellow** | `matmul_blocked` |
| **Near threshold** (≤1.2×) | `num_cholesky` 1.20×, `cloth_swing` 1.10×, `matmul_naive` 1.05×, `num_opt_line_search` 1.04×, `md_thermostat_berendsen` 1.03× |
| `*_pure_li` red | **None** on dashboard ingest |
| Open `novel-algorithm` / `autoresearch` issues (lic) | **0** |
| Prior autoresearch runs today | 4× **error** (tool/MCP); this run unblocks tier-1 verify |

---

## Finding: `horner_pure_li` oracle drift (harness, not codegen)

**Hypothesis tested:** tier-1 verify failure blocks PH-7e evidence for `horner_pure_li`.  
**Root cause:** `benchmarks/harness/reference.py` had `HORNER_BENCH_X = 1.1` while `horner_core.c` and pure-Li `main.li` use `0.999999`. Full-step analytical oracle at `x=1.1` overflows (`inf`) → `bench.py` aborts before CSV.

**Fix (this run):** align `HORNER_BENCH_X` to `0.999999` (comment already cited `horner_core.c`).

**Repro:**

```bash
cd lic && ./scripts/build.sh
python3 benchmarks/harness/bench.py --tier 1 --only horner_pure_li,matmul_blocked,matmul_naive,simd_dot --runs 3
./scripts/check-tier1-li-vs-cpp.sh
```

---

## Negative / deferred (novel autoresearch)

| Candidate | Verdict | Reason |
|-----------|---------|--------|
| MD cell-linked neighbor (algo 105) | **Defer** | SOTA survey done (`2026-05-27-md-r0-sota-survey.md`); needs **implementation + parity**, not new discrete scheme |
| `matmul_blocked` yellow | **Defer to codegen/7e** | SOTA = blocked IKJ + FMA; win is lowering/SIMD, not new algorithm |
| Near-threshold physics (`cloth_swing`, …) | **Defer** | Within catalog ratio; autoresearch gate requires inadequate SOTA + novel method |
| Berendsen thermostat 1.03× | **Defer** | Published method; tune parameters / codegen only |

---

## Recommended next PR (if ratios improve)

**Title:** `fix(bench): align horner_pure_li reference x with horner_core.c`  
**Repo:** `lic` · **Labels:** `autoresearch`, `numerics-research`  
**Evidence:** `benchmarks/results/latest.csv` + `check-tier1-li-vs-cpp.sh` after fix

<!-- li-agent -->
## Agent deliverable
- [x] li-tests or lit test id: `benchmarks/harness/test_reference_analytical.py::test_horner_tier1_oracle_matches_bench_x`
- [x] Bench row / benchmarks path: `horner_pure_li`, `matmul_blocked`, `matmul_naive`, `simd_dot` — `benchmarks/results/latest.csv`
- [x] Lean/contracts path documented or N/A with reason: N/A — harness float oracle only; no `trusted.lean` change
- [x] Negative result documented if hypothesis rejected: novel-algorithm candidates deferred in table above

---

## Quality table (local devbox, post-fix @ 2026-05-29)

| Bench id | Li/cpp ratio | Verify | Notes |
|----------|--------------|--------|-------|
| `horner_pure_li` | **0.800×** | pass | pure_li; was blocked by `HORNER_BENCH_X` drift |
| `matmul_blocked` | **1.287×** | pass | catalog **yellow**; codegen/7e, not novel algo |
| `matmul_naive` | **1.056×** | pass | within 1.2× cap |
| `simd_dot` | **0.973×** | pass | shared C kernel (DCE guard) |

---

## Commands checklist

```bash
python3 -m unittest benchmarks.harness.test_reference_analytical -v
python3 benchmarks/harness/bench.py --tier 1 --only horner_pure_li,matmul_blocked,matmul_naive,simd_dot --runs 3
./scripts/check-tier1-li-vs-cpp.sh
# benchmarks repo ingest (separate PR):
# cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
```
