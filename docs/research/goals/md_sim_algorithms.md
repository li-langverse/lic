# Research goal digest — `md_sim_algorithms`

**Session:** `f1114f06-7079-45f3-9d88-ce5106130118` · **Cycle:** 1 · **Agent:** `numerics_researcher`  
**Run:** `numerics_researcher-1779914639840` · **Generated:** 2026-05-27T21:00:00Z  
**North star fit:** MD algorithms — SOTA survey and Li gap analysis — domains: scientific_computing, hpc (PH-5b, PH-7e)

---

## Executive summary

- **Mode A SOTA survey complete** (`md-r0`): LAMMPS, GROMACS, OpenMM, and Frenkel–Smit / Swope NVE literature mapped to **algo_registry 101–120** with implementation ordering (neighbor 105 → integrators → thermostats/PME).
- **Li gap:** All **16 `md_*` catalog rows are unknown** on the [dashboard](https://li-langverse.github.io/benchmarks/) (stale ingest); org **red** remains tier-1 `horner_pure_li` / `reduce_sum`, not MD physics.
- **`md_lennard_jones`** is the only production-grade tier-2 path (brute O(N²) MIC via `md_core.c`); prior harness run reports verify drift ≈0.689 and li/cpp ≈0.996× — validity baseline, not a neighbor-list win.
- **`li-sim-scientific`:** `run_algo_registry_stub` for ids **101–117** returns checksum **1.001**; only **101** (`md_lj_cutoff_mic`) and **102** (`md_integrator_verlet`) call `run_md_lj_smoke`.
- **WP2 stubs:** 13 `md_*` harness dirs alias `md_lennard_jones` oracle — **`md_neighbor_cell_list` (105)** has catalog row but no cell traversal yet (`md-r2` handoff).
- **v1 implement target:** `sim-p1-md-neighbor-cell` — cell-linked forces with max |F_cell − F_brute| gate before any `ratio_vs_cpp` claim on 105.
- **Whitepaper + evidence:** [md-r0 whitepaper](../../../../research-findings/whitepapers/2026-05/md_sim_algorithms/md-r0-sota-survey/README.md) · [md-r1 stability matrix (study-only seed)](../../../../research-findings/whitepapers/2026-05/md_sim_algorithms/md-r1-stability-matrix/README.md) (`validity_grade: study-only`).
- **No perf claims** this cycle; `threshold_ratio_cpp` and tier-0 tolerances unchanged.

---

## Deliverable / findings

### Completed artifacts (cycle 1)

| Step | Artifact |
|------|----------|
| `survey_sota` | [Whitepaper](../../../../research-findings/whitepapers/2026-05/md_sim_algorithms/md-r0-sota-survey/README.md) · bench/li-tests evidence in `artifacts.json` |
| Session log | `docs/ecosystem/research-sessions/md_sim_algorithms-cycle.md` |
| This digest | `docs/research/goals/md_sim_algorithms.md` |

### Learned from (SOTA, 2–4)

1. [LAMMPS neighbor lists](https://docs.lammps.org/neighbor.html) — skin, binning, rebuild criteria → **105/106** implement contract.
2. [GROMACS algorithms manual](https://manual.gromacs.org/current/reference-manual/algorithms/index.html) — search grids, constraints, PME scope → registry **107–120** staged after short-range parity.
3. [OpenMM application guide](https://docs.openmm.org/latest/userguide/application.html) — cutoffs, thermostats, drift testing → tier-0 stability row proposal (`md-r1`).
4. [Frenkel & Smit — *Understanding Molecular Simulation*](https://www.sciencedirect.com/book/9780123872324/understanding-molecular-simulation) + [Swope et al. 1997](https://doi.org/10.1006/jcph.1997.5740) — cell-linked O(N); NVE drift gates for `md_energy_drift`.

### Li mapping (PH / proof)

| Surface | PH / group | Status |
|---------|------------|--------|
| `md_core.c` oracle, `stability.py` | PH-5b | Production on `md_lennard_jones` |
| Force loop + `num_integ_verlet` microbench | PH-7e | Deferred until neighbor parity |
| `requires dt > 0`, drift bounds | G-math | numerical policy + `[conservation]` in params.toml |
| `parallel for (disjoint=)` on force loop | G-par | Post-proof only |

### In-repo gap evidence (verified)

```167:195:packages/li-sim-scientific/src/lib.li
def run_algo_registry_stub(algo_id: int, detail: int) -> SimRunResult
  ...
  if algo_id >= 101:
    if algo_id <= 117:
      vert = vertical_md_lennard_jones()
  ...
  r.checksum = 1.001
  return r
```

```206:211:packages/li-sim-scientific/src/lib.li
  if algo_id == algo_md_lj_cutoff_mic():
    return run_md_lj_smoke(d0)
  if algo_id == algo_md_integrator_verlet():
    return run_md_lj_smoke(d1)
```

Registry snapshot: `research-findings/whitepapers/2026-05/md_sim_algorithms/md-r0-sota-survey/snippets/algo-registry-md-101-120.md`.

### Grade matrix

| Axis | Li today | Target | Locked? |
|------|----------|--------|---------|
| Validity | LJ harness + WP2 stubs on 105/106; cell list unproven | checksum parity on 105 | **yes** |
| Stability | `[conservation]` in params.toml; md-r1 matrix placeholder | tier-0 fill (≥3 N) | **yes** |
| Accuracy | brute MIC reference | cell vs brute max \|ΔF\| | **yes** |
| Performance | all `md_*` unknown on dashboard | after parity on 105 | no (deferred) |
| Memory | N/A | `sim-bench-memory.sh` post-105 | no |

### Tradeoffs

Validity, stability (energy drift, neighbor skin), and accuracy (force parity) remain **locked**. Speed on neighbor/constraint/PME rows is deferred until checksum parity and a ≥3-size scaling table are green. Do not relax `threshold_ratio_cpp` or tier-0 tolerances.

### Mandatory evidence (this run)

| Type | Path |
|------|------|
| Whitepaper | `research-findings/whitepapers/2026-05/md_sim_algorithms/md-r0-sota-survey/` |
| Whitepaper (stability seed) | `research-findings/whitepapers/2026-05/md_sim_algorithms/md-r1-stability-matrix/` |
| li-tests | `li-tests/composable/import_sim_scientific_run.li` (manifest row) |
| Bench catalog | `benchmarks/catalog.toml` → `md_lennard_jones`, `md_neighbor_cell_list` |
| Preflight | `benchmarks/data/latest/ecosystem-audit.json` (16 unknown `md_*`) |
| Harness command | `python3 benchmarks/harness/bench.py --tier 2 --only md_lennard_jones` |

### Implementation path (handoff → `bench_improver` / sim worktree)

1. **`sim-p1-md-neighbor-cell`:** implement cell-linked traversal in `md_core` for algo **105**; gate max |F_cell − F_brute|.
2. Fill **md-r1** size-scaling table (N ∈ {128, 512, 2048}) from harness + `stability.py`.
3. Run `ingest-lic.sh` so `md_lennard_jones` exits dashboard **unknown**.
4. Replace `run_algo_registry_stub` for **105** with real dispatch after parity.
5. Deep gates in `lic-worktrees/sim-md-research` only — no new systemd sim loops on main.

---

## Recommended issues/PRs

| Title | Repo | Labels | Owner agent |
|-------|------|--------|-------------|
| `md-r2: cell neighbor list — brute-force parity (algo 105)` | `lic` | `numerics-research`, `bench` | `bench_improver` / `sim-p1-md-neighbor-cell` |
| `md-r1: fill CFL / skin scaling table (≥3 N) for md_lennard_jones` | `lic` | `numerics-research` | `numerics_researcher` |
| `ingest-lic: refresh md_* dashboard rows from tier-2 harness` | `benchmarks` | `numerics-research`, `bench` | `bench_improver` |
| `docs(numerics): land 2026-05-27-md-r0-sota-survey study on main` | `lic` | `numerics-research` | `numerics_researcher` (PR #319 follow-up) |
| `Honesty: verticals.toml md_neighbor_cell_list until 105 parity` | `benchmarks` | `numerics-research` | `bench_improver` |

**PR template reminder (when opening lic PR):**

```markdown
<!-- li-agent -->
## Agent deliverable
- [x] Tests added or updated — cite `li-tests/composable/import_sim_scientific_run.li`
- [x] Bench evidence — `md_lennard_jones` / `md_neighbor_cell_list` catalog rows; https://li-langverse.github.io/benchmarks/
- [x] No merge-approved until human review
```

---

## Deferred

- **`md-r3-oracle-plan`** — external LAMMPS binary oracle (document only until driver exists).
- **Thermostats / barostats / PME (107–120)** — after short-range neighbor validity on 105.
- **PH-7e SIMD / `@parallel` force loop** — after proof + parity locked.
- **Native perf claims on `md_neighbor_cell_list`** — after md-r1 scaling table and ingest green.
- **Autoresearch** — novel splittings only if SOTA path insufficient (`numerics-autoresearch` gates).

---

## Links

- [Benchmark dashboard](https://li-langverse.github.io/benchmarks/)
- [Sim MD backlog](../../ecosystem/sim-md-research-backlog.md)
- [Grading rubric](../../ecosystem/sim-algo-research-grading.md)
- [Goal scaffold](../../../../li-cursor-agents/config/goal-scaffolds/md_sim_algorithms.md)
- [md-r0 whitepaper](../../../../research-findings/whitepapers/2026-05/md_sim_algorithms/md-r0-sota-survey/README.md)
