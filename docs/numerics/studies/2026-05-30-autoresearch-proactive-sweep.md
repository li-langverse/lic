# Autoresearch proactive sweep — 2026-05-30

**north_star_fit:** provable + blazingly-fast (PH-5b, PH-7e) — triage codegen reds vs novel-algorithm scope  
**Status:** negative result — no novel kernel shipped; handoffs filed for bench_improver / numerics_researcher  
**Run:** `autoresearch-1780146986895` (proactive ecosystem sweep)

## Executive summary

Proactive briefing refresh (2026-05-30T12:07Z) lists six dashboard **red** tier-1 rows; local ecosystem audit (2026-05-30T12:52Z, partial ingest) shows **zero reds**, two **yellow** (`matmul_blocked`, `matmul_naive`). None of the current reds qualify for **Mode B autoresearch** without repeating SOTA codegen work already assigned to `bench_improver`.

## Triage table

| Bench id | Dashboard ratio | Root cause class | Agent lane |
|----------|----------------|------------------|------------|
| `matmul_blocked` | 1.549× | PH-7e blocked `@` MIR/codegen (IKJ tiles) | **bench_improver** — study `2026-05-30-matmul-blocked-7e.md`, PR #541 |
| `matmul_naive` | 1.333× | PH-7e loop matmul lowering | **bench_improver** — same PR stack |
| `horner_pure_li` | (was 88×, fixed) | Lexer `+` bug — **closed autoresearch** | Done — `autoresearch-horner-lexer-2026-05-18.md` |
| `num_gmres` | 1.4× | Shared-C wrapper (`LI_EXTRA_C`), not pure-Li | **bench_improver** / harness — not novel Krylov |
| `ml_conv2d_forward` | 1.333× | **li-math** repo (`algo_registry`) | **numerics_researcher** in li-math |
| `ml_mlp_*` | 1.333× | **li-math** repo | **numerics_researcher** in li-math |

Local `lic/benchmarks/results/latest.csv` (pre-ingest, sha `b655309b`): `matmul_naive` **1.01×** (pass), `matmul_blocked` **1.88×** (fail), `horner_pure_li` **2.33×** (fail vs 1.2× pure_li gate — needs rebuild after #543).

## Autoresearch candidates (novel-algorithm lane)

| Target | Why autoresearch | Prerequisite |
|--------|------------------|--------------|
| `md_thermostat_berendsen` | Yellow on dashboard; Li-specific symplectic+dissipative splitting may beat cpp oracle | Mode A SOTA survey (Nosé-Hoover chains, deterministic variants) |
| `md_thermostat_nose_hoover` | Same | Stability sweeps + tier-2 GIF evidence |
| Near-threshold tier-2 (`cloth_swing`, `robo_*`) | 1.05–1.17× — algorithm/registry tuning, not lexer/codegen | Physics visual validation |

**Rejected this pass:** inventing a new GMRES/preconditioner in lic — harness uses shared C oracle; pure-Li path absent; would not beat 1.2× without codegen parity first.

## Commands (repro)

```bash
# Briefing + audit
cat /home/s4il0r/Documents/Cursor/li-langverse/benchmarks/data/latest/agent-briefing.json | jq '.ecosystem_audit.benchmarks'
cat /home/s4il0r/Documents/Cursor/li-langverse/benchmarks/data/latest/ecosystem-audit.json | jq '.benchmarks'

# Local tier-1 ratios
cd lic/benchmarks/harness
python3 bench.py --tier 1 --runs 3 --only matmul_blocked,matmul_naive,horner_pure_li
python3 -c "import csv; ..."  # li/cpp from benchmarks/results/latest.csv
```

## Evidence paths

- Study: `docs/numerics/studies/2026-05-30-autoresearch-proactive-sweep.md` (this file)
- Prior autoresearch win: `docs/numerics/autoresearch-horner-lexer-2026-05-18.md`
- Bench improver in-flight: `docs/numerics/studies/2026-05-30-matmul-blocked-7e.md`
- Bench row catalog: `benchmarks/catalog.toml` (`horner_pure_li` `variant = "pure_li"`)
- Lean/contracts: N/A — triage only, no kernel change

## Negative result

**Hypothesis:** At least one dashboard red row is codegen-bound pure-Li work suitable for a **novel** numerical method (Mode B).  
**Outcome:** **Rejected.** All six reds decompose into (a) MIR/codegen fixes, (b) shared-C harness overhead, or (c) sibling-repo (`li-math`) SOTA adoption — not autoresearch invention scope.
