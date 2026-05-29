# Autoresearch proactive sweep — 2026-05-29

**Agent:** `autoresearch` · **Run:** `autoresearch-1780071613727` · **Source:** proactive  
**North star:** PH-5b (proved numerics), PH-7e (math→SIMD/codegen) · **G-math**  
**Preflight:** `benchmarks/data/latest/ecosystem-audit.json` @ 2026-05-29T16:22Z · [dashboard](https://li-langverse.github.io/benchmarks/)

---

## Executive summary

- Dashboard shows **6 tier-1 red** rows (all `ratio_vs_cpp` > 1.2×): `matmul_blocked` **1.549×** (worst), `matmul_naive` **1.333×**, three ML micro rows, `num_gmres` **1.4×**; **137 green**, **2 yellow** (MD thermostats).
- **`horner_pure_li`** is **green** at **0.75×** cpp (lexer fix + anti-DCE); autoresearch win documented in [autoresearch-horner-lexer-2026-05-18.md](../autoresearch-horner-lexer-2026-05-18.md); [lic#388](https://github.com/li-langverse/lic/pull/388) CI green — merge before new codegen work.
- **P0 autoresearch target:** `matmul_blocked` — pure-Li driver delegates hot path to `mm_blocked_512` → `ArrayMatMulBlocked2DF64` MIR; three competing CI-green PRs (#380, #397, #401) claim ≤1.2× after MIR fusion — **consolidate stack, ingest, close duplicate PRs**.
- **No novel-algorithm issue** labeled open; physics/chem SOTA surveys (`md-r0`, `chem-r0`) are **study-only** — autoresearch defers tier-2 physics until `numerics_researcher` closes neighbor-list / validity gaps.
- Local `bench.py --tier 1 --only matmul_blocked` **blocked** (lic binary missing at `build/compiler/lic/lic`); evidence relies on dashboard ingest + open PR bodies.
- **Negative result this pass:** no new discrete scheme invented — incremental PH-7e codegen fusion (not novel numerics) is the correct lever for reds; ML/`num_gmres` reds share identical 1.333×/1.4× ratios suggesting harness/oracle coupling, not kernel invention.
- **Control plane:** 9 prior `autoresearch` runs today ended `error` (digest-only / tooling); this run produces sweep record only.

---

## Deliverable / findings

### Quality table (dashboard @ ingest)

| Bench id | ratio_vs_cpp | status | Autoresearch axis | Notes |
|----------|--------------|--------|-------------------|-------|
| `matmul_blocked` | **1.549** | red | speed (codegen) | MIR blocked IKJ exists; fusion PRs claim 1.187–1.23× local |
| `matmul_naive` | 1.333 | red | speed (codegen) | Same PH-7e lowering family as blocked |
| `ml_conv2d_forward` | 1.333 | red | speed | Shared oracle timing — investigate before novel algo |
| `ml_mlp_forward` | 1.333 | red | speed | Same |
| `ml_mlp_train_step` | 1.333 | red | speed | Same |
| `num_gmres` | 1.4 | red | speed | Iterative micro — SOTA = PETSc/ Eigen patterns, not new GMRES |
| `horner_pure_li` | **0.75** | green | — | Prior autoresearch: lexer `+`/`−` bug |
| `num_cholesky` | 1.167 | near | speed | Defer until tier-1 reds clear |

### Hypothesis evaluated (matmul_blocked MIR fusion)

**Hypothesis:** Fusing init + blocked GEMM + checksum sink into a single MIR lowering removes branchy Li loops from the timed region and brings `matmul_blocked` ≤1.2× cpp.

**Falsification metric:** `bench.py --tier 1 --only matmul_blocked --verify-results`; checksum `1288460.7564000632`.

**Status:** **In flight** — [lic#397](https://github.com/li-langverse/lic/pull/397) reports **1.187×**; [lic#401](https://github.com/li-langverse/lic/pull/401) **1.230×** on agent host. Not a *novel* algorithm (standard cache-blocked IKJ + SIMD); publish via perf PR + ingest, not `novel-algorithm` note.

### Prior autoresearch (closed)

| Slug | Result | Evidence |
|------|--------|----------|
| `horner-lexer-2026-05-18` | **Accepted fix** | Lexer `+`→`Minus` bug; 71.7× → 0.26× local |
| `md-r0-sota-survey` | Study-only | Delegate to `numerics_researcher` for algo 105 cell list |
| `chem-r0-qm-sota-survey` | Study-only | QM vertical — no autoresearch kernel this pass |

### Repro (blocked locally)

```bash
cd lic && ./scripts/build.sh
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_blocked --runs 8 --verify-results
./scripts/check-tier1-li-vs-cpp.sh
cd ../benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
```

---

## Recommended issues / PRs

| Action | Repo | Title / id | Labels |
|--------|------|------------|--------|
| **Merge first** | lic | [PR #388](https://github.com/li-langverse/lic/pull/388) — fix(bench): unblock horner_pure_li tier-1 verify | autoresearch |
| **Pick one, close dupes** | lic | [PR #397](https://github.com/li-langverse/lic/pull/397) or [#401](https://github.com/li-langverse/lic/pull/401) — matmul_blocked MIR fusion ≤1.2× | PH-7e |
| **Supersede or rebase** | lic | [PR #380](https://github.com/li-langverse/lic/pull/380) — FMA + 8-wide SIMD (older approach) | PH-7e |
| **Human: pr_alignment** | lic | Stack warnings: #377 vs #374/#367/#373 — pick one studio/ML wave | governance |
| **Next numerics_researcher** | lic | MD neighbor cell list (algo 105) — [md-r0 study](./2026-05-27-md-r0-sota-survey.md) | numerics-research |
| **Catalog hygiene** | lic/benchmarks | [PR #378](https://github.com/li-langverse/lic/pull/378) — tier paths → benchmarks repo | ecosystem |
| **File (optional)** | lic | `[autoresearch] matmul_naive + ML tier-1 red triage — oracle vs codegen` | novel-algorithm, autoresearch |

---

## Deferred

- **Tier-2 physics autoresearch** (cell-linked neighbors, PME, thermostats) until `md_neighbor_cell_list` harness exits WP2 stub and NVE drift matrix filled (`md-r1`).
- **Novel integrators / preconditioners** for `num_gmres` — SOTA survey required; ratio 1.4× likely codegen not algorithm gap.
- **ML micro reds** — identical 1.333× across conv2d/mlp suggests shared harness artifact; triage before `@vectorized` invention.
- **`matmul_blocked_N1024` / `matmul_naive_N1024`** — unknown ingest; size sweep after 512³ green.
- **Trusted.lean / new axioms** — any invariant-preserving tile schedule needs human-approved issue first.
- **Local bench rebuild** — agent workspace lacks built `lic`; next pass must `./scripts/build.sh` before claiming fresh ratios.

---

<!-- li-agent -->
## Agent deliverable
- [x] li-tests or lit test id: N/A — sweep-only; evidence cites existing tier-1 harness + PR #397/#388 bodies
- [x] Bench row / benchmarks path: `matmul_blocked`, `horner_pure_li` @ `benchmarks/tier1_micro/`
- [x] Lean/contracts path documented or N/A with reason: N/A — codegen/MIR only; no trusted.lean changes
- [x] Negative result documented if hypothesis rejected: yes — no novel algorithm shipped; matmul fusion delegated to open PRs
